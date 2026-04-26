{ config, lib, pkgs, osConfig, niri-flake, noctalia-shel, ... } : let

  niriEnable = ( osConfig.programs.niri.enable && !osConfig.services.desktopManager.gnome.enable );
  
in {

  imports = [
    niri-flake.homeModules.niri
    ./settings
    ./waybar
    ./noctalia
  ];

  config = lib.mkIf niriEnable {

    programs.emacs.package = lib.mkForce pkgs.emacs-pgtk;
    services.emacs.package = lib.mkForce pkgs.emacs-pgtk;
    
    home.packages = with pkgs; [
      adwaita-icon-theme
      nautilus
    ];

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-wlr
      ];
    };

    programs.niri = {
      enable = osConfig.programs.niri.enable;
      package = pkgs.niri;
    };
    
    programs.fuzzel = lib.mkIf (!config.programs.noctalia-shell.enable) {
      enable = true;
      package = pkgs.fuzzel;
      settings = {
        main = {
          terminal = "${lib.getExe config.programs.kitty.package}";
          icon-theme = "Adwaita";
          layer = "overlay";
        };
      };
    };
    
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        
        clock = true;
        daemonize = true;
        ignore-empty-password = false;
        show-failed-attempts = true;
        show-keyboard-layout = true;
        hide-keyboard-layout = false;
        
        indicator = true;
        indicator-caps-lock = true;
        indicator-idle-visible = true;
        indicator-radius = 250;
        indicator-thickness = 15;

        scaling = "fill";
        timestr = "%H:%M:%S";
        datestr = "%Y-%m-%d %a";
        # font-size = 128;
        
        screenshots = true;
        effect-blur = "10x5";
        effect-vignette = "0.5:0.5";
        grace = 0;
        fade-in = 0;
        
        text-color = "ffffff";
        inside-color = "00000049";
        ring-color = "ffffff";
        line-color = "00000000";

        text-caps-lock-color = "ff00ff";
        inside-caps-lock-color = "00000049";
        ring-caps-lock-color = "ffffff";
        line-caps-lock-color = "00000000";

        separator-color = "ffd700";
        bs-hl-color = "ff0000";
        key-hl-color = "0000ff";
        caps-lock-bs-hl-color = "ff4900";
        caps-lock-key-hl-color = "0049ff";

        text-ver-color = "004900";
        inside-ver-color = "00ff00";
        ring-ver-color = "008100";
        line-ver-color = "00000000";

        text-wrong-color = "490000";
        inside-wrong-color = "ff0000";
        ring-wrong-color = "810000";
        line-wrong-color = "00000000";

        text-clear-color = "494900";
        inside-clear-color = "ffff00";
        ring-clear-color = "818100";
        line-clear-color = "00000000";

        layout-bg-color = "00000000";
        layout-border-color = "00000000";
        layout-text-color = "ffffff";

      };
    };

    services.mako = lib.mkIf (!config.programs.noctalia-shell.enable) {
      enable = true; # notification daemon
      package = pkgs.mako;
      settings = {
        anchor = "top-left";
        default-timeout = 10000;
        width = 200;
        height = 30;
        margin = 0;
        padding = 0;
        border-radius = 0;
        border-size = 1;
        icons = true;
        markup = true;
        actions = true;
        group-by = "app-name";
      };
    };
    
    services.swayidle = lib.mkIf (!config.programs.noctalia-shell.settings.idle.enabled) {
      enable = true; # idle management daemon
      package = pkgs.swayidle;
      systemdTargets = [
        config.wayland.systemd.target
      ];
      extraArgs = [
        "-w"
      ];
      events = {
        after-resume = "${lib.getExe config.programs.niri.package} msg action power-on-monitors";
        before-sleep = builtins.concatStringsSep "&&" [
          "${lib.getExe config.programs.swaylock.package} -fF"
          "${lib.getExe config.programs.niri.package} msg action power-off-monitors"
        ];
        lock = "${lib.getExe config.programs.swaylock.package} -fF";
        unlock = "${lib.getExe config.programs.niri.package} msg action power-on-monitors";
      };
      timeouts = [
        {
          timeout = 300;
          command = "${lib.getExe config.programs.swaylock.package} -f";
        }
        {
          timeout = 600;
          command = "${lib.getExe config.programs.niri.package} msg action power-off-monitors";
          resumeCommand = "${lib.getExe config.programs.niri.package} msg action power-on-monitors";
        }
        {
          timeout = 1200;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
    
    services.polkit-gnome = {
      enable = false;
      package = pkgs.polkit_gnome;
    };
    
    services.gnome-keyring.enable = false;
    
    services.cliphist = {
      enable = true;
      package = pkgs.cliphist;
      clipboardPackage = pkgs.wl-clipboard;
      systemdTargets = "${config.wayland.systemd.target}";
      allowImages = true;
      extraOptions = [
        "-max-dedupe-search"
        "10"
        "-max-items"
        "100"
      ];
    };
    
    services.clipse = {
      enable = false;
      package = pkgs.clipse;
      historySize = 100;
      allowDuplicates = true;
      systemdTarget = "${config.wayland.systemd.target}";
      keyBindings = {};
      imageDisplay = {
        type = "kitty";
        heightCut = 2;
        scaleX = 9;
        scaleY = 9;
      };
      theme = {
        useCustomTheme = false;
      };
    };
    
  };

}
