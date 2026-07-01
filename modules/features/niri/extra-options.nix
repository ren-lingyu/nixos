feature_ : { config, pkgs, lib, ... } : {
  
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
  
  monitor = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
      example = "eDP-1";
      description = "Name of the primary monitor.";
    };
    width = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 3072;
      example = 3072;
      description = "Width of the primary monitor in pixels.";
    };
    height = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 1920;
      example = 1920;
      description = "Height of the primary monitor in pixels.";
    };
  };
  
}
