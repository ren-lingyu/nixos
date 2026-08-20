{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.workloads.caddy.existModule = {
      os = true;
      hm = false;
    };
  };

}
