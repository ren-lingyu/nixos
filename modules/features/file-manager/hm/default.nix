{ config, osConfig, lib, pkgs, ... } : let

  cfg = osConfig.modules.features.file-manager;
  niriCfg = osConfig.modules.features.niri;

in {

  config = lib.mkIf cfg.enable {

    programs.yazi = {
      enable = true;
      package = pkgs.yazi;
      enableZshIntegration = config.programs.zsh.enable;
      enableBashIntegration = config.programs.bash.enable;
    };

    programs.wayfile = lib.mkIf niriCfg.enable {
      enable = niriCfg.enable;
      package = pkgs.wayfile;
      mimeTypes = [
        "inode/directory"
      ];
    };

    xdg = {
      mimeApps = {
        enable = true;
        defaultApplications = lib.mkIf (!niriCfg.enable) {
          "inode/directory" = "yazi.desktop";
        };
      };
    };

  };

}
