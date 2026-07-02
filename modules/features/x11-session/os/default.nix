{ config, pkgs, lib, ... } : let
  
  cfg = config.modules.features.x11-session;

in {
  
  config = lib.mkIf cfg.enable {
    
    services.xserver = {
      enable = true;
      
      displayManager = {
        startx.enable = true;
      };
      
      desktopManager.xfce = {
        enable = true;
        enableScreensaver = true;
        enableWaylandSession = true;
        waylandSessionCompositor = "";
        enableXfwm = true;
        noDesktop = false;
      };
      
    };
    
  };
  
}
