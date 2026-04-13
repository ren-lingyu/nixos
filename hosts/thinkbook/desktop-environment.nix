{ config, lib, pkgs, ... } : let

  gnomeEnable = true;
  hyprlandEnable = false;
  niriEnable = true;
  deEnable = gnomeEnable;
  wmEnable = ( hyprlandEnable || niriEnable );
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
    portal = lib.mkIf ( wmEnable && !deEnable ) {
      enable = false; # hyprlandEnable;
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

  # niri
  programs.niri = {
    enable = niriEnable;
    package = pkgs.niri;
    useNautilus = true;
  };

  # hyprland
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
  };

  services = {
    hypridle = {
      enable = hyprlandEnable;
      package = pkgs.hypridle;
    };
  };

  # services and programs enabled in wm
  services = {
    tumbler = {
      enable = ( wmEnable && !deEnable );
    };
    gvfs = lib.mkIf (!gnomeEnable) {
      enable = ( wmEnable && !deEnable );
      package = pkgs.gnome.gvfs;
    };
  };

  programs = {
    thunar = {
      enable = ( wmEnable && !deEnable );
      plugins = with pkgs; [
        thunar-volman
        thunar-archive-plugin
      ];
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

  programs = {
    kdeconnect = {
      enable = gnomeEnable;
      package = pkgs.valent;
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
