{ config, pkgs, lib, ... } : {

  config = {
    modules.features.office.existModule = {
      os = false;
      hm = true;
    };
  };

}
