{ config, lib, pkgs, osConfig, ... } : {

  config = {
    
    programs.thunderbird = {
      enable = osConfig.programs.thunderbird.enable;
      package = pkgs.thunderbird;
    };
    
  };

}
