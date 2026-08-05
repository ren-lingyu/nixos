{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.features.file-manager.existModule = {
      os = true;
      hm = true;
    };
  };

}
