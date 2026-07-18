feature_ : { options, config, pkgs, lib, ... } : {

  noctalia.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.modules.features.${feature_}.enable;
    example = true;
    description = "Whether to enable the Noctalia shell configuration for Niri.";
  };

  waybar.enable = lib.mkOption {
    type = lib.types.bool;
    default =
      !config.modules.features.${feature_}.noctalia.enable
      && config.modules.features.${feature_}.enable;
    example = false;
    description = "Whether to enable the Waybar status bar for Niri.";
  };

  session-wrapper = lib.mkOption {
    type = lib.types.unique {
      message = "Only one module may define `modules.features.${feature_}.session-wrapper.package`.";
    } (lib.types.nullOr lib.types.package);
    default = null;
    internal = true;
    description = "Internal package providing the niri session command for greeters.";
  };

  monitors = let
    positiveInt_ = lib.types.addCheck lib.types.ints.unsigned (x_ : x_ > 0);
    positiveFloat_ = lib.types.addCheck lib.types.float (x_ : x_ > 0);
  in lib.mkOption {
    type = lib.types.unique {
      message = "Only one module may define `modules.features.${feature_}.monitors`.";
    } (lib.types.attrsOf (lib.types.submodule ({ name, config, ... } : {
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
        scale = lib.mkOption {
          type = lib.types.nullOr positiveFloat_;
          default = null;
          example = 1.6;
          description = "Scale of the monitor in pixels.";
        };
      };
    })));
    internal = true;
    default = {};
    description = "Monitor declarations used by Niri.";
  };

}
