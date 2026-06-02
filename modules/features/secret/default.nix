{ config, lib, pkgs, ... } : {

  imports = [
    ./os
  ];
  
  options = {
    modules.features.secret = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
      os.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.modules.features.secret.enable;
        example = true;
      };
      hm.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.modules.features.secret.enable;
        example = true;
      };
    };
  };

  config = lib.mkMerge [
    
    {
      assertions = [
        {
          assertion = !config.modules.features.secret.os.enable || config.modules.features.secret.enable;
          message = "`modules.features.secret.os.enable = true` requires `modules.features.secret.enable = true;`.";
        }
        {
          assertion = !config.modules.features.secret.hm.enable || config.modules.features.secret.enable;
          message = "`modules.features.secret.hm.enable = true` requires `modules.features.secret.enable = true;`.";
        }
      ];
    }
    
    (lib.mkIf (config.modules.features.secret.enable && config.modules.features.secret.hm.enable) {
      home-manager.users = {
        "${builtins.toString config.modules.users.uid}" = {
          imports = [
            ./hm
          ];
        };
      };
    })
    
  ];
  
}
