{ config, lib, pkgs, ... } : let

  hyprlandAdditionEnable = ( config.programs.hyprland.enable && !config.services.desktopManager.gnome.enable );
  
in {

  programs = lib.mkIf hyprlandAdditionEnable {
    hyprlock = {
      enable = config.programs.hyprland.enable;
      package = pkgs.hyprlock;
    };
    thunar = {
      enable = config.programs.hyprland.enable;
      plugins = with pkgs; [
        thunar-volman
        thunar-archive-plugin
      ];
    };
  };

  services = lib.mkIf hyprlandAdditionEnable {
    hypridle = {
      enable = config.programs.hyprland.enable;
      package = pkgs.hypridle;
    };
    tumbler = {
      enable = config.programs.hyprland.enable;
    };
    gvfs = {
      enable = config.programs.hyprland.enable;
      package = pkgs.gnome.gvfs;
    };
  };

  security = {
    soteria = lib.mkIf hyprlandAdditionEnable {
      enable = config.programs.hyprland.enable;
      package = pkgs.soteria;
    };
  };

  environment.systemPackages = with pkgs; lib.mkIf config.programs.hyprland.enable [
    kitty
  ];
  
}
