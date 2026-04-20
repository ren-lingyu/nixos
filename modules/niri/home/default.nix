{ config, lib, pkgs, osConfig, niri-flake, ... } : let

  niriEnable = ( osConfig.programs.niri.enable && !osConfig.services.desktopManager.gnome.enable );
  
in {

  imports = [
    niri-flake.homeModules.niri
    ./settings
    ./waybar
  ];

  config = lib.mkIf niriEnable {

    programs.emacs.package = lib.mkForce pkgs.emacs-pgtk;
    services.emacs.package = lib.mkForce pkgs.emacs-pgtk;

    home.packages = with pkgs; [
      adwaita-icon-theme
    ];

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        # pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
    };

    programs = {
      niri = {
        enable = osConfig.programs.niri.enable;
        package = pkgs.niri;
      };
      fuzzel = {
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
      swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          clock = true;
          color = "000000";
          font-size = 32;
          indicator-idle-visible = true;
          indicator-radius = 200;
          indicator-thickness = 15;
          line-color = "ffffff";
          show-failed-attempts = true;
          effect-blut = "10x5";
        };
      };
    };

    services = {
      mako = {
        enable = true; # notification daemon
        package = pkgs.mako;
        settings = {
          anchor = "top-right";
          default-timeout = 0;
          width = 0;
          height = 0;
          margin = 10;
          padding = 10;
          border-radius = 0;         
          border-size = 1;
          icons = true;
          markup = true;
          actions = true;
          group-by = "app-name";
        };
      };
      swayidle = {
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
            "${lib.getExe config.programs.niri.package} msg action power-off-monitors"
            "${lib.getExe config.programs.swaylock.package} -fF"
          ];
          lock = builtins.concatStringsSep "&&" [
            "${lib.getExe config.programs.niri.package} msg action power-off-monitors"
            "${lib.getExe config.programs.swaylock.package} -fF"
          ];
          unlock = "${lib.getExe config.programs.niri.package} msg action power-on-monitors";
        };
        timeouts = [
          {
            timeout = 300;
            command = "${lib.getExe config.programs.swaylock.package} -fF";
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
      polkit-gnome = {
        enable = true;
        package = pkgs.polkit_gnome;
      };
      gnome-keyring.enable = false;
      cliphist = {
        enable = true;
        package = pkgs.cliphist;
        clipboardPackage = pkgs.wl-clipboard;
        systemdTarget = "${config.wayland.systemd.target}";
        allowImages = true;
        extraOptions = [
          "-max-dedupe-search"
          "10"
          "-max-items"
          "100"
        ];
      };
      clipse = {
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
    
  };

}
