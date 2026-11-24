{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.features.file-manager;

in
{
  options.features.file-manager = {
    fileChooser.enable = lib.mkEnableOption "Yazi file chooser";
  };

  config = {
    environment.pathsToLink = lib.optionals cfg.fileChooser.enable [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };
}
