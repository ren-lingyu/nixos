{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.hosts.aliyun = {
      enable = true;
      existModule = {
        os = true;
        hm = false;
      };
    };
  };

}
