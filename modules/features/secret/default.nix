{ config, lib, pkgs, ... } : {

  imports = [
    ./os
  ];
  
  config = {
    modules.features.secret.existModule = {
      os = true;
      hm = true;
    };
  };
  
}
