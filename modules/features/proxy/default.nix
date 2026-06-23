{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];
  
  config = {
    modules.features.proxy.existModule = {
      os = true;
      hm = false;
    };
    assertions = [
      {
        assertion = !config.modules.features.proxy.clash.enable || config.modules.features.proxy.enable;
        message = "`modules.features.proxy.clash.enable = true` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = !config.modules.features.proxy.v2raya.enable || config.modules.features.proxy.enable;
        message = "`modules.features.proxy.v2raya.enable = true` is only allowed when `modules.features.proxy.enable = true;`.";
      }
    ];
  };
  
}
