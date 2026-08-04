{ options, config, pkgs, lib, ... } : let

  cfg = config.modules.hosts;
  hostList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : ((type_ == "directory") && (builtins.pathExists (./. + "/${name_}/default.nix")))) (builtins.readDir ./.));

in {

  options = {
    modules.hosts = (builtins.listToAttrs (builtins.map (host_ : {
      name = host_;
      value = let
        possibleExtraOptionsPath_ = ./. + "/${builtins.toString host_}/extra-options.nix";
      in {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to enable this host profile.";
        };
        users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.unique {
            message = "Each `modules.hosts.${host_}.users.<uid>` can only be defined once.";
          } lib.types.ints.unsigned);
          internal = true;
          default = {};
          example = {
            "1000" = 1000;
          };
          description = "UID-keyed declarations of managed users registered for this host.";
        };
        monitors = lib.mkOption {
          type = lib.types.attrsOf (lib.types.unique {
            message = "Each `modules.hosts.${host_}.monitors.<name>` can only be defined once.";
          } (lib.types.submodule (
            { name, config, ... } : {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  default = name;
                  example = "eDP-1";
                  description = "Name of the monitor.";
                };
                role = lib.mkOption {
                  type = lib.types.nullOr (lib.types.enum [
                    "default"
                  ]);
                  default = null;
                  description = "The roles of the monitor.";
                };
                mode = let
                  positiveInt_ = lib.types.addCheck lib.types.ints.unsigned (x_ : x_ > 0);
                  positiveFloat_ = lib.types.addCheck lib.types.float (x_ : x_ > 0);
                in lib.mkOption {
                  type = lib.types.nullOr (lib.types.submodule {
                    options = {
                      width = lib.mkOption {
                        type = positiveInt_;
                        example = 3072;
                        description = "Width of the monitor mode in pixels.";
                      };
                      height = lib.mkOption {
                        type = positiveInt_;
                        example = 1920;
                        description = "Height of the monitor mode in pixels.";
                      };
                      refresh = lib.mkOption {
                        type = lib.types.nullOr positiveFloat_;
                        default = null;
                        example = 60.0;
                        description = "Refresh rate of the monitor mode in Hz.";
                      };
                    };
                  });
                  default = null;
                  example = {
                    width = 3072;
                    height = 1920;
                    refresh = 60.0;
                  };
                  description = "Preferred monitor mode.";
                };
                scale = let
                  positiveFloat_ = lib.types.addCheck lib.types.float (x_ : x_ > 0);
                in lib.mkOption {
                  type = lib.types.nullOr positiveFloat_;
                  default = null;
                  example = 1.6;
                  description = "Scale of the monitor in pixels.";
                };
              };
            }
          )));
          internal = true;
          default = {};
          example = {
            "eDP-1" = {
              name = "eDP-1";
              role = "default";
              mode = {
                width = 3072;
                height = 1920;
                refresh = 60.0;
              };
              scale = 1.6;
            };
          };
          description = "Monitor declarations for this host.";
        };
        existModule = {
          os = lib.mkOption {
            type = lib.types.unique {
              message = "Only one module may define `modules.hosts.${host_}.existModule.os`.";
            } (lib.types.nullOr lib.types.bool);
            internal = true;
            default = null;
            example = true;
            description = "Whether the ${host_} host profile has an OS module.";
          };
          hm = lib.mkOption {
            type = lib.types.unique {
              message = "Only one module may define `modules.hosts.${host_}.existModule.hm`.";
            } (lib.types.nullOr lib.types.bool);
            internal = true;
            default = null;
            example = true;
            description = "Whether the ${host_} host profile has a Home Manager module.";
          };
        };
      } // (lib.optionalAttrs (builtins.pathExists possibleExtraOptionsPath_) (
        (import possibleExtraOptionsPath_) host_ {
          inherit options;
          inherit config;
          inherit pkgs;
          inherit lib;
        }
      ));
    }) hostList_));
  };

  config = {

    assertions = let
      enabledHosts_ = lib.filterAttrs (unused_name_ : host_ : host_.enable) cfg;
      enabledHostNames_ = builtins.attrNames enabledHosts_;
    in (builtins.concatLists [
      [
        {
          assertion = (builtins.length enabledHostNames_) <= 1;
          message = "At most one host in `modules.hosts` may set `enable = true`. Enabled hosts: ${builtins.concatStringsSep ", " enabledHostNames_}.";
        }
      ]
      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : [
        {
          assertion = host_.existModule.os == null || host_.existModule.os == builtins.pathExists (./. + "/${hostName_}/os/default.nix");
          message = "`modules.hosts.${hostName_}.existModule.os` must match whether `${builtins.toString (./. + "/${hostName_}/os/default.nix")}` exists.";
        }
        {
          assertion = host_.existModule.hm == null || host_.existModule.hm == builtins.pathExists (./. + "/${hostName_}/hm/default.nix");
          message = "`modules.hosts.${hostName_}.existModule.hm` must match whether `${builtins.toString (./. + "/${hostName_}/hm/default.nix")}` exists.";
        }
        {
          assertion = (host_.existModule.os == null) == (host_.existModule.hm == null);
          message = "`modules.hosts.${hostName_}.existModule.os` and `modules.hosts.${hostName_}.existModule.hm` must either both be declared or both be `null`.";
        }
        {
          assertion = !host_.enable || (host_.existModule.os != null && host_.existModule.hm != null);
          message = "`modules.hosts.${hostName_}.enable = true` requires the host profile to declare `existModule.os` and `existModule.hm`.";
        }
      ]) cfg))
      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : (builtins.concatLists [
        (let
          monitors_ = builtins.attrValues host_.monitors;
          defaultMonitors_ = builtins.filter (monitor_ : monitor_.role == "default") monitors_;
          monitorNames_ = builtins.map (monitor_ : monitor_.name) monitors_;
        in [
          {
            assertion = (builtins.length defaultMonitors_) <= 1;
            message = "At most one monitor in `modules.hosts.${hostName_}.monitors` may set `role = \"default\"`.";
          }
          {
            assertion = (builtins.length monitorNames_) == (builtins.length (lib.unique monitorNames_));
            message = "Monitor names in `modules.hosts.${hostName_}.monitors` must be unique.";
          }
        ])
        (builtins.concatLists (lib.mapAttrsToList (uidKey_ : uid_ : [
          {
            assertion = builtins.match "^[0-9]+$" uidKey_ != null;
            message = "`modules.hosts.${hostName_}.users.${uidKey_}` must use a numeric UID string as its attribute name, like `modules.hosts.${hostName_}.users.\"1000\"`.";
          }
          {
            assertion = (builtins.match "^[0-9]+$" uidKey_ != null) && (uidKey_ == builtins.toString uid_);
            message = "`modules.hosts.${hostName_}.users.${uidKey_}` must use the canonical decimal representation of UID ${builtins.toString uid_}.";
          }
        ]) host_.users))
        (lib.mapAttrsToList (monitorName_ : monitor_ : {
          assertion = monitor_.name != "";
          message = "`modules.hosts.${hostName_}.monitors.${monitorName_}.name` must not be empty.";
        }) host_.monitors)
      ])) cfg))
    ]);

    home-manager.sharedModules = builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ :
      lib.optionals (host_.enable && host_.existModule.hm == true) [
        (./. + "/${hostName_}/hm")
      ]
    ) cfg);

  };

}
