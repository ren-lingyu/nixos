{ config, lib, ... } : let

  cfg = config.modules.features.file-manager;

in {

  config = lib.mkIf cfg.enable {

    environment.pathsToLink = lib.optionals cfg.fileChooser.enable [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

  };

}
