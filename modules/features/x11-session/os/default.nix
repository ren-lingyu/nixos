{ config, pkgs, lib, ... } : let
  
  cfg = config.modules.features.x11-session;

in {
  
  config = lib.mkIf cfg.enable {
    
    services.xserver = {
      enable = true;
      
      displayManager = {
        startx.enable = true;
      };
      
      windowManager.icewm = {
        enable = true;
      };
      
    };
    
    environment.systemPackages = with pkgs; [
      xdg-utils
      xrandr
    ];
    
  };
  
}
