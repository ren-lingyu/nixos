{ config, lib, pkgs, ... } : let

  cfg = config.modules.features.agent;

in {
  
  config = {
    
    modules.features.agent.existModule = {
      os = false;
      hm = true;
    };
    
    assertions = [
      {
        assertion = !cfg.enable || config.modules.features.secret.enable;
        message = "`modules.features.agent.enable = true` requires `modules.features.secret.enable = true`.";
      }
    ];
    
  };
  
}
