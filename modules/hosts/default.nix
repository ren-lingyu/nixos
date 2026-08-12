{ options, config, pkgs, lib, llib, ... } : let

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
          } llib.types.monitor);
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
        intranetClaims = lib.mkOption {
          type = lib.types.unique {
            message = "`modules.hosts.${host_}.intranetClaims` can only be defined once.";
          } (lib.types.attrsOf (lib.types.listOf lib.types.nonEmptyStr));
          internal = true;
          example = {
            ingress = [ "hub" ];
          };
          description = "Interconnect nodes claimed by this host, grouped by intranet name.";
        };
        publicIpAddress = lib.mkOption {
          type = lib.types.unique {
            message = "`modules.hosts.${host_}.publicIpAddress` can only be defined once.";
          } (lib.types.nullOr lib.types.str);
          internal = true;
          default = null;
          example = "203.0.113.10";
          description = "Public IP address assigned to this host.";
        };
        publicHostKey = lib.mkOption {
          type = lib.types.unique {
            message = "`modules.hosts.${host_}.publicHostKey` can only be defined once.";
          } (lib.types.submodule {
            options = builtins.listToAttrs (builtins.map (keyFormat_ : {
              name = keyFormat_;
              value = lib.mkOption {
                type = lib.types.nullOr lib.types.nonEmptyStr;
                default = null;
                description = "Public ${keyFormat_} key used to identify this host.";
              };
            }) [ "age" "ssh" ]);
          });
          internal = true;
          default = {};
          example = {
            age = "age1...";
            ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...";
          };
          description = "Public identity keys for this host, grouped by key format.";
        };
        existModule = lib.mkOption {
          type = llib.types.existModule {
            optionPath = "modules.hosts.${host_}.existModule";
          };
          internal = true;
          default = {};
          description = "Module availability declared by the ${host_} host profile.";
        };
      } // (lib.optionalAttrs (builtins.pathExists possibleExtraOptionsPath_) (
        (import possibleExtraOptionsPath_) host_ {
          inherit options;
          inherit config;
          inherit pkgs;
          inherit lib;
          inherit llib;
        }
      ));
    }) hostList_));
  };

  config = {

    modules.hosts = (builtins.listToAttrs
      (builtins.map
        (host_ : {
          name = host_;
          value = let
            possibleMetadataPath_ = ./. + "/${builtins.toString host_}/metadata.nix";
          in (lib.optionalAttrs
            (builtins.pathExists possibleMetadataPath_)
            ((import possibleMetadataPath_)
              host_
              {
                inherit config;
                inherit pkgs;
                inherit lib;
                inherit llib;
              }
            )
          );
        })
        hostList_
      )
    );

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
      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : llib.assertions.existModule {
        enable = host_.enable;
        value = host_.existModule;
        optionPath = "modules.hosts.${hostName_}.existModule";
        osModulePath = ./. + "/${hostName_}/os/default.nix";
        hmModulePath = ./. + "/${hostName_}/hm/default.nix";
        enabledMessage = "`modules.hosts.${hostName_}.enable = true` requires the host profile to declare `existModule.os` and `existModule.hm`.";
      }) cfg))
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
      ])) cfg))
    ]);

    home-manager.sharedModules = builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ :
      lib.optionals (host_.enable && host_.existModule.hm == true) [
        (./. + "/${hostName_}/hm")
      ]
    ) cfg);

  };

}
