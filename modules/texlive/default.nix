{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];
  
  options = {
    modules.texlive = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
}
