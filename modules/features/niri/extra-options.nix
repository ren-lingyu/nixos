feature_ : { options, config, pkgs, lib, llib, ... } : {

  noctalia.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.modules.features.${feature_}.enable;
    example = true;
    description = "Whether to enable the Noctalia shell configuration for Niri.";
  };

  waybar.enable = lib.mkOption {
    type = lib.types.bool;
    default = (builtins.all
      (x_ : x_)
      [
        (!config.modules.features.${feature_}.noctalia.enable)
        config.modules.features.${feature_}.enable
      ]
    );
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

  monitors = lib.mkOption {
    type = lib.types.unique {
      message = "Only one module may define `modules.features.${feature_}.monitors`.";
    } llib.types.monitors;
    internal = true;
    default = {};
    description = "Monitor declarations used by Niri.";
  };

}
