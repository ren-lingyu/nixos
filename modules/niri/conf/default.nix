{ config, lib, pkgs, ... } : {

  imports = [
    ./greeter.nix
  ];

  config = {
    programs.niri.enable = true;

    services.desktopManager.gnome.enable = false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;
  };
  
}
