{ config, lib, pkgs, ... } : {

  imports = [
    ./gnome.nix
    ./hyprland.nix
  ];

  services.desktopManager.gnome.enable = false;
  services.gnome.gnome-keyring.enable = lib.mkForce false;
  
  programs.hyprland = {
    enable = false;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    withUWSM = true;
    xwayland = {
      enable = true;
    };
  };

}
