{ config, lib, pkgs, ... }:

{

  services = {
    displayManager = {
      gdm = {
        enable = false;
        wayland = true;
      };
    };
    desktopManager = {
      gnome = {
        enable = false;
      };
    };
    gnome = {
      gnome-keyring = {
        enable = false;
      };
    };
  };

}
