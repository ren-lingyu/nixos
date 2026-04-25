{ config, lib, pkgs, ... } : {

  imports = [
    ./gnome.nix
    ./hyprland.nix
  ];

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    libnotify
  ];

  services.desktopManager.gnome.enable = false;
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  programs.niri.enable = true;
  
  programs.hyprland = {
    enable = false;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    withUWSM = true;
    xwayland = {
      enable = true;
    };
  };

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

}
