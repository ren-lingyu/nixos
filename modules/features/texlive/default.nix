{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.features.texlive.existModule = {
      os = true;
      hm = false;
    };
  };
  
}
