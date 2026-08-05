{ config, pkgs, lib, ... } : {

  config = {
    modules.features.terminal.existModule = {
      os = false;
      hm = true;
    };
  };

}
