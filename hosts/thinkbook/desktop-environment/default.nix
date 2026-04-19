{ config, lib, pkgs, ... } : {

  imports = [
    ./gnome.nix
    ./hyprland.nix
    ./niri.nix
  ];

  services.desktopManager.gnome.enable = false;

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    useNautilus = true;
  };
  
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
