{ config, lib, pkgs, ... }:

let

  gnomeEnable = true;
  hyprlandEnable = false;
  greetdEnable = false;
  gdmEnale = true;
  
in

{

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
    tumbler = {
      enable = hyprlandEnable;
    };
    gvfs = {
      enable = true;
      package = pkgs.gnome.gvfs;
    };
    displayManager = {
      gdm = {
        enable = gdmEnale;
        wayland = true;
      };
    };
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

  security = {
    soteria = {
      enable = hyprlandEnable;
      package = pkgs.soteria;
    };
  };

}
