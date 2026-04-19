{ config, lib, pkgs, osConfig, ... } : let

  niriAdditionEnable = ( osConfig.programs.niri.enable && !osConfig.services.desktopManager.gnome.enable );
  
in {

  config = lib.mkIf niriAdditionEnable {

    programs = {
      fuzzel = {
        enable = true; # app launcher
        package = pkgs.fuzzel;
        settings = {};
      };
      swaylock = {
        enable = true;
        package = pkgs.swaylock;
        settings =  {};
      };
      waybar = {
        enable = true;
        package = pkgs.waybar;
        settings = {};
        style = null;
        systemd = {
          enable = true;
          targets = [ config.wayland.systemd.target ];
          enableDebug = false;
          enableInspect = false;
        };
      };
    };

    services = {
      mako = {
        enable = true; # notification daemon
        package = pkgs.mako;
        settings = {
          anchor = "top-right";
          default-timeout = 0;
          width = 0;
          height = 0;
          margin = 10;
          padding = 10;
          border-radius = 0;         
          border-size = 1;
          icons = true;
          markup = true;
          actions = true;
          group-by = "app-name";
        };
      };
      swayidle = {
        enable = true; # idle management daemon
        package = pkgs.swayidle;
      };
      polkit-gnome = {
        enable = true;
        package = pkgs.polkit_gnome;
      };
    };
    
  };

}
