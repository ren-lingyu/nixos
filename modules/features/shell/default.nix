{ config, lib, pkgs, ... } : {

  imports = [
    ./os
  ];
  
  options = {
    modules.shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
}
