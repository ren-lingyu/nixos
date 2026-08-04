{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.hosts.wsl = {
      enable = true;
      users = {
        "1000" = 1000;
      };
      existModule = {
        os = true;
        hm = false;
      };
    };
  };

}
