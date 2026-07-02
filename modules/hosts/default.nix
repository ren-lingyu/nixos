{ config, pkgs, lib, ... } : {
  
  options = {
    modules.hosts = {
      monitors = lib.mkOption {
        type = lib.types.attrsOf (lib.types.unique {
          message = "Each `monitor.<name>` can only be defined once.";
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
  };
  
  config = {
    
    assertions = let
      monitors_ = builtins.attrValues config.modules.hosts.monitors;
      defaultMonitors_ = builtins.filter (monitor_ : monitor_.role == "default") monitors_;
      monitorNames_ = builtins.map (monitor_ : monitor_.name) monitors_;
    in (builtins.concatLists [
      [
        {
          assertion = (builtins.length defaultMonitors_) <= 1;
          message = "At most one monitor in `modules.hosts.monitors` may set `role = \"default\"`.";
        }
        {
          assertion = (builtins.length monitorNames_) == (builtins.length (lib.unique monitorNames_));
          message = "Monitor names in `modules.hosts.monitors` must be unique.";
        }
      ]
      (lib.mapAttrsToList (monitorName_ : monitor_ : {
        assertion = monitor_.name != "";
        message = "`modules.hosts.monitors.${monitorName_}.name` must not be empty.";
      }) config.modules.hosts.monitors)
    ]);
    
  };
  
}
