{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];
  
  config = {
    modules.features.media.existModule = {
      os = true;
      hm = false;
    };
  };
  
}
