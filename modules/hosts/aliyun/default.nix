{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.hosts.aliyun = {
      enable = true;
      users = {
        "1000" = 1000;
      };
    };
  };

}
