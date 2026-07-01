{ config, pkgs, lib, ... } : {
  
  config = lib.mkIf config.modules.features.niri.enable {

    programs.niri = {
      enable = config.modules.features.niri.enable;
      package = pkgs.niri;
    };
    
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
    
    services.desktopManager.gnome.enable = lib.mkForce false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    
  };
  
}
