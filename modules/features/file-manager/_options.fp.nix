{
  config,
  lib,
  path,
  ...
}:
let
  feature_ = lib.last path;
in
{
  configuration = {
    fileChooser.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.modules.features.${feature_}.enable;
      example = false;
      description = "Whether to use Yazi as the XDG Desktop Portal file chooser.";
    };
  };
  metadata = { };
}
