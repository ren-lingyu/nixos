{ config, lib, pkgs, osConfig, niri-flake, ... } : let

  niriEnable = ( osConfig.programs.niri.enable && !osConfig.services.desktopManager.gnome.enable );
  
in {

  imports = [
    niri-flake.homeModules.niri
    ./settings/top-level.nix
    ./settings/input.nix
    ./settings/outputs.nix
    ./settings/layout.nix
    ./settings/animations.nix
    ./settings/window-rules.nix
    ./settings/binds.nix
  ];

  config = lib.mkIf niriEnable {

    programs.emacs.package = lib.mkForce pkgs.emacs-pgtk;
    services.emacs.package = lib.mkForce pkgs.emacs-pgtk;

    home.packages = with pkgs; [
      adwaita-icon-theme
    ];

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        # pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
    };

    programs = {
      niri = {
        enable = osConfig.programs.niri.enable;
        package = pkgs.niri;
      };
      fuzzel = {
        enable = true;
        package = pkgs.fuzzel;
        settings = {
          main = {
            terminal = "${lib.getExe config.programs.kitty.package}";
            icon-theme = "Adwaita";
            layer = "overlay";
          };
        };
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
      gnome-keyring.enable = false;
    };
    
  };

}
