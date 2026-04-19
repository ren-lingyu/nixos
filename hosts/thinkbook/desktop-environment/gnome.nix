{ config, lib, pkgs, ... } : {

  config = lib.mkIf config.services.desktopManager.gnome.enable {
    
    services = {
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      gnome = {
        gnome-software.enable = false;
        gnome-user-share.enable = false;
        gnome-keyring.enable = false;
        gnome-online-accounts.enable = false;
        gnome-browser-connector.enable = true;
        gnome-settings-daemon.enable = true;
        core-apps.enable = true;
        core-shell.enable = true;
        games.enable = false;
      };
    };
      
  };
  
}
