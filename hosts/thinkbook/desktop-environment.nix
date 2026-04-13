{ config, lib, pkgs, ... } : let

  gnomeEnable = true;
  hyprlandEnable = false;
  greetdEnable = false;
  gdmEnale = true;
  defaultBrowser = "microsoft-edge.desktop";
  
in {

  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/https" = defaultBrowser;
        "x-scheme-handler/http" = defaultBrowser;
        "text/html" = defaultBrowser;
        "text/xml" = defaultBrowser;
        "application/xhtml+xml" = defaultBrowser;
        "application/pdf" = defaultBrowser;
        "x-scheme-handler/about" = defaultBrowser;
        "x-scheme-handler/unknown" = defaultBrowser;
      };
    };
    portal = lib.mkIf (hyprlandEnable && !gnomeEnable) {
      enable = hyprlandEnable;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
      ];
      config.common.default = [
        "gtk"
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      kitty
    ];
  };
  
  programs = {
    hyprland = {
      enable = hyprlandEnable;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      withUWSM = true;
      xwayland = {
        enable = true;
      };
    };
    hyprlock = {
      enable = hyprlandEnable;
      package = pkgs.hyprlock;
    };
    thunar = {
      enable = hyprlandEnable;
      plugins = with pkgs; [
        thunar-volman
        thunar-archive-plugin
      ];
    };
  };
  
  programs = {
    kdeconnect = {
      enable = gnomeEnable;
      package = pkgs.valent;
    };
  };
  
  services = {
    hypridle = {
      enable = hyprlandEnable;
      package = pkgs.hypridle;
    };
    tumbler = {
      enable = hyprlandEnable;
    };
    gvfs = lib.mkIf (!gnomeEnable) {
      enable = hyprlandEnable;
      package = pkgs.gnome.gvfs;
    };
  };
  
  # gnome
  services = {
    desktopManager = {
      gnome = {
        enable = gnomeEnable;
      };
    };
    gnome = {
      gnome-software.enable = false;
      gnome-user-share.enable = false;
      gnome-keyring.enable = false;
      gnome-online-accounts.enable = false;
      gnome-browser-connector.enable = true;
      gnome-settings-daemon.enable = true;
      core-apps.enable = true;
      core-shell.enable = true;
      games.enable = false;
    };
  };

  # greeters
  services = {
    displayManager = {
      gdm = {
        enable = gdmEnale;
        wayland = true;
      };
    };
    greetd = {
      enable = greetdEnable;
      package = pkgs.greetd;
      useTextGreeter = false;
      settings = {
        default_session = {
          command = lib.escapeShellArgs [
            "${lib.getExe pkgs.tuigreet}"
            "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
            "--time"
            "--time-format '%Y-%m-%d %H:%M:%S'"
            "--asterisks"
            "--remember"
            "--remember-session"
          ];
        };
      };
    };
  };
  
  security = {
    soteria = {
      enable = hyprlandEnable;
      package = pkgs.soteria;
    };
  };

}
