{ config, lib, pkgs, ... } : {
  
  config = {
    
    modules.features.agent.existModule = {
      os = false;
      hm = true;
    };
    
    assertions = [
      {
        assertion = !config.modules.features.agent.enable || config.modules.features.secret.enable;
        message = "`modules.features.agent.enable = true` requires `modules.features.secret.enable = true`.";
      }
    ];
    
  };
  
}
