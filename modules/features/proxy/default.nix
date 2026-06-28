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
        assertion = !config.modules.features.proxy.clash-verge.enable || config.modules.features.proxy.enable;
        message = "`modules.features.proxy.clash-verge.enable = true;` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = !config.modules.features.proxy.throne.enable || config.modules.features.proxy.enable;
        message = "`modules.features.proxy.throne.enable = true;` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = !config.modules.features.proxy.mihomo.enable || config.modules.features.proxy.enable;
        message = "`modules.features.proxy.mihomo.enable = true;` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = !config.modules.features.proxy.v2raya.enable || config.modules.features.proxy.enable;
        message = "`modules.features.proxy.v2raya.enable = true;` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = (lib.count (x : x) [
          config.modules.features.proxy.clash-verge.enable
          config.modules.features.proxy.mihomo.enable
        ]) <= 1;
        message = "At most one of `modules.features.proxy.clash-verge.enable`, and `modules.features.proxy.mihomo.enable` can be true.";
      }
    ];
  };
  
}
