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
              mode = lib.mkOption {
                type = lib.types.nullOr (lib.types.submodule {
                  options = {
                    width = lib.mkOption {
                      type = lib.types.ints.unsigned;
                      example = 3072;
                      description = "Width of the monitor mode in pixels.";
                    };
                    height = lib.mkOption {
                      type = lib.types.ints.unsigned;
                      example = 1920;
                      description = "Height of the monitor mode in pixels.";
                    };
                    refresh = lib.mkOption {
                      type = lib.types.nullOr lib.types.float;
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
              scale = lib.mkOption {
                type = lib.types.nullOr lib.types.float;
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
  
}
