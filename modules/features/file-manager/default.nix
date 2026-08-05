{ config, pkgs, lib, ... } : {

  config = {
    modules.features.file-manager.existModule = {
      os = false;
      hm = true;
    };
  };

}
