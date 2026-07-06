{ config, pkgs, lib, ... } : let

  cfg = config.modules.hosts;

in {
  
  options = {
    modules.hosts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (
        { name, config, ... } : {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              example = true;
              description = "Whether to enable this host profile.";
            };
            monitors = lib.mkOption {
              type = lib.types.attrsOf (lib.types.unique {
                message = "Each `modules.hosts.${name}.monitors.<name>` can only be defined once.";
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
            packageGroups = {
              tencent.enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                example = true;
                description = "Whether to install Tencent package group on this host.";
              };
            };
          };
        }
      ));
      default = {};
      description = "Host profile configurations.";
    };
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
      (lib.mapAttrsToList (hostName_ : host_ : {
        assertion = !host_.enable || builtins.pathExists (./. + "/${hostName_}/default.nix");
        message = "`modules.hosts.${hostName_}.enable = true` requires `${builtins.toString (./. + "/${hostName_}/default.nix")}` to exist.";
      }) cfg)
      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : let
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
      ] ++ (lib.mapAttrsToList (monitorName_ : monitor_ : {
        assertion = monitor_.name != "";
        message = "`modules.hosts.${hostName_}.monitors.${monitorName_}.name` must not be empty.";
      }) host_.monitors)) cfg))
    ]);
    
  };
  
}
