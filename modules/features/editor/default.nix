{ config, pkgs, lib, ... } : {

  config = {
    modules.features.editor.existModule = {
      os = false;
      hm = true;
    };
  };

}
