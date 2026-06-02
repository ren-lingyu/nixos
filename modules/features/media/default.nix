{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];
  
  options = {
    modules.features.media = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
}
