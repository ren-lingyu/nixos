{ config, lib, pkgs, ... } : let

  cfg = config.modules.features.diagnostics;

in {

  config = {

    modules.features.diagnostics.existModule = {
      os = false;
      hm = true;
    };

  };

}
