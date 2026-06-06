{ config, lib, pkgs, ... } : {

  config = {
    
    modules.features.cloud.existModule = {
      os = true;
      hm = true;
    };
    
    assertions = [
      {
        assertion = !config.modules.features.cloud.enable || config.modules.features.secret.enable;
        message = "`modules.features.cloud.enable = true` requires `modules.features.secret.enable = true`.";
      }      
    ];
    
  };
  
}
