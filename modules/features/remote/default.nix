{ config, lib, pkgs, ... } : {

  config = {
    
    modules.features.remote.existModule = {
      os = true;
      hm = true;
    };
    
    assertions = [
      {
        assertion = !config.modules.features.remote.enable || config.modules.features.secret.enable;
        message = "`modules.features.remote.enable = true` requires `modules.features.secret.enable = true`.";
      }
    ];
    
  };
  
}
