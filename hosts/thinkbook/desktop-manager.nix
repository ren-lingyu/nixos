{ config, lib, pkgs, ... }:

{

  services = {
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager = {
      gnome = {
        enable = true;
      };
    };
    gnome = {
      gnome-keyring = {
        enable = false;
      };
    };
  };

}
