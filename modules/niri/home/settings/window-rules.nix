{ config, lib, pkgs, osConfig, niri-flake, ... } : {

  config = lib.mkIf config.programs.niri.enable {
    
    programs.niri.settings.window-rules = [];
    
  };

}
