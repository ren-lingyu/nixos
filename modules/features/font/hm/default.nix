{ config, pkgs, lib, osConfig, ... } : {

  config = lib.mkIf osConfig.modules.features.font.enable {

    fonts.fontconfig = {
      enable = true;
      defaultFonts = osConfig.fonts.fontconfig.defaultFonts;
    };
    
  };
  
}
