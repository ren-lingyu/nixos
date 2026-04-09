{ config, lib, pkgs, ... }:

let

  gnomeEnable = true;
  hyprlandEnable = false;
  
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
      enable = hyprlandEnable;
      package = pkgs.greetd;
      useTextGreeter = false;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
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
        enable = gnomeEnable;
        wayland = true;
      };
    };
    desktopManager = {
      gnome = {
        enable = gnomeEnable;
      };
    };
    gnome = {
      gnome-keyring = {
        enable = false;
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
