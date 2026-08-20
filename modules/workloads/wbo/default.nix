{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];

  config = {
    modules.workloads.wbo.existModule = {
      os = true;
      hm = false;
    };
  };

}
