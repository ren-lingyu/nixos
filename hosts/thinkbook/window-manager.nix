{ config, lib, pkgs, ... }:

{

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    hyprlock = {
      enable = true;
    };
  };

  services = {
    hypridle = {
      enable = true;
    };
    greetd = {
      enable = true;
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
  };

}
