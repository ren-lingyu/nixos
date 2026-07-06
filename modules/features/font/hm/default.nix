{ config, pkgs, lib, osConfig, ... } : let

  cfg = osConfig.modules.features.font;

in {

  config = lib.mkIf cfg.enable {

    fonts.fontconfig = {
      enable = true;
      defaultFonts = osConfig.fonts.fontconfig.defaultFonts;
    };
    
  };
  
}
