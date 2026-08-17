{ config, osConfig, lib, pkgs, ... } : let

  cfg = osConfig.modules.features.file-manager;
  niriCfg = osConfig.modules.features.niri;

in {

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = (builtins.any
          (x_ : x_)
          [
            (!cfg.fileChooser.enable)
            config.xdg.terminal-exec.enable
          ]
        );
        message = "`modules.features.file-manager.fileChooser.enable = true` requires `xdg.terminal-exec.enable = true`.";
      }
    ];

    programs.yazi = {
      enable = true;
      package = pkgs.yazi;
      enableZshIntegration = config.programs.zsh.enable;
      enableBashIntegration = config.programs.bash.enable;
      extraPackages = [
        pkgs.fd
        pkgs.ripgrep
        pkgs.fzf
        pkgs.zoxide
      ];
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
      portal = lib.mkIf cfg.fileChooser.enable {
        enable = true;
        extraPortals = [
          pkgs.xdg-desktop-portal-termfilechooser
        ];
        config.common."org.freedesktop.impl.portal.FileChooser" = [
          "termfilechooser"
        ];
      };
      configFile = {
        "xdg-desktop-portal-termfilechooser/config" = lib.mkIf cfg.fileChooser.enable {
          enable = true;
          target = "xdg-desktop-portal-termfilechooser/config";
          text = (builtins.concatStringsSep "\n" [
            "[filechooser]"
            "cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh"
            "default_dir=$HOME"
            "env=TERMCMD=${lib.getExe config.xdg.terminal-exec.package}"
            "open_mode=suggested"
            "save_mode=suggested"
            ""
          ]);
        };
      };
    };

  };

}
