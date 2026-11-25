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
  options = {
    features.file-manager = {
      enable = lib.mkEnableOption "system file manager integration";
      fileChooser.enable = lib.mkEnableOption "Yazi file chooser" // {
        default = cfg.enable;
      };
    };
  };

  config = lib.mkIf config.features.file-manager.enable {
    environment.pathsToLink = lib.optionals cfg.fileChooser.enable [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };
}
