{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.hosts.wsl = {
      enable = true;
      existModule = {
        os = true;
        hm = false;
      };
    };
  };

}
