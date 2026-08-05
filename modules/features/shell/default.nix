{ config, lib, pkgs, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.features.shell = {
      existModule = {
        os = true;
        hm = true;
      };
      zsh = {
        package = pkgs.zsh;
      };
      bash = {
        package = pkgs.bashInteractive;
      };
    };
  };

}
