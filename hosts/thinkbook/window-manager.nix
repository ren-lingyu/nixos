{ config, lib, pkgs, ... }:

{

  programs = {
    hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      withUWSM = true;
      xwayland = {
        enable = true;
      };
    };
    hyprlock = {
      enable = true;
      package = pkgs.hyprlock;
    };
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-volman
        thunar-archive-plugin
      ];
    };
  };

  services = {
    hypridle = {
      enable = true;
      package = pkgs.hypridle;
    };
    greetd = {
      enable = true;
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
    gvfs = {
      enable = true;
      package = pkgs.gnome.gvfs;
    };
    tumbler = {
      enable = true;
    };
  };

  security = {
    soteria = {
      enable = true;
      package = pkgs.soteria;
    };
  };

}
