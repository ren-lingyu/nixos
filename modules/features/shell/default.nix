{ config, lib, pkgs, ... } : {

  imports = [
    ./os
  ];
  
  options = {
    modules.features.shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
}
