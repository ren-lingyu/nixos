{
  config,
  lib,
  llib,
  path,
  ...
}:
let
  feature_ = lib.last path;
in
{
  configuration = {

    noctalia.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.features.${feature_}.enable;
      example = true;
      description = "Whether to enable the Noctalia shell configuration for Niri.";
    };

    waybar.enable = lib.mkOption {
      type = lib.types.bool;
      default = (
        builtins.all (x_: x_) [
          (!config.modules.features.${feature_}.noctalia.enable)
          config.modules.features.${feature_}.enable
        ]
      );
      example = false;
      description = "Whether to enable the Waybar status bar for Niri.";
    };

  };
  metadata = { };
}
