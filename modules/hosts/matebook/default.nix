{ config, pkgs, lib, ... } : let

  cfg = config.modules.hosts.matebook;

in {

  imports = [
    ./os
  ];

  config = {

    modules.hosts.matebook = {
      enable = true;
      existModule = {
        os = true;
        hm = false;
      };
    };

  };

}
