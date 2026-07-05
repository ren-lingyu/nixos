{ config, osConfig, pkgs, lib, ... } : {
  
  config = lib.mkIf osConfig.modules.features.x11-session.enable {
    
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
    };
    
  };
  
}
