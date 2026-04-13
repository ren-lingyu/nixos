{ config, lib, pkgs, ... } : let

  hyprlandShellEnable = ( !config.services.displayManager.gdm.enable && config.programs.hyprland.enable );
  
in {

  # hyprland system modules
  programs = {
    hyprland = {
      enable = false;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      withUWSM = true;
      xwayland = {
        enable = true;
      };
    };
    hyprlock = {
      enable = config.programs.hyprland.enable;
      package = pkgs.hyprlock;
    };
  };

  services.hypridle = {
    enable = config.programs.hyprland.enable;
    package = pkgs.hypridle;
  };

  environment.systemPackages = with pkgs; lib.mkIf config.programs.hyprland.enable [
    kitty
  ];

  services.tumbler = lib.mkIf hyprlandShellEnable {
    enable = config.programs.hyprland.enable;
  };
  
  services.gvfs = lib.mkIf hyprlandShellEnable {
    enable = config.programs.hyprland.enable;
    package = pkgs.gnome.gvfs;
  };

  programs.thunar = lib.mkIf hyprlandShellEnable {
      enable = config.programs.hyprland.enable;
      plugins = with pkgs; [
        thunar-volman
        thunar-archive-plugin
      ];
    };

  security.soteria = lib.mkIf hyprlandShellEnable {
    enable = config.programs.hyprland.enable;
    package = pkgs.soteria;
  };
  
}
