{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.proxy;

in {

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
        assertion = !cfg.clash-verge.enable || cfg.enable;
        message = "`modules.features.proxy.clash-verge.enable = true;` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = !cfg.throne.enable || cfg.enable;
        message = "`modules.features.proxy.throne.enable = true;` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = !cfg.mihomo.enable || cfg.enable;
        message = "`modules.features.proxy.mihomo.enable = true;` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = !cfg.v2raya.enable || cfg.enable;
        message = "`modules.features.proxy.v2raya.enable = true;` is only allowed when `modules.features.proxy.enable = true;`.";
      }
      {
        assertion = (lib.count (x : x) [
          cfg.clash-verge.enable
          cfg.mihomo.enable
        ]) <= 1;
        message = "At most one of `modules.features.proxy.clash-verge.enable`, and `modules.features.proxy.mihomo.enable` can be true.";
      }
    ];
  };
  
}
