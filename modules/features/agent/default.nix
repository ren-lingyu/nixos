{ config, lib, pkgs, ... } : {
  
  options = {
    modules.features.agent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
  config = lib.mkMerge [

    {
      assertions = [
        {
          assertion = !config.modules.features.agent.enable || config.modules.features.secret.enable;
          message = "`modules.features.agent.enable = true` requires `modules.features.secret.enable = true;`.";
        }
      ];
    }
    
    (lib.mkIf config.modules.features.agent.enable {
      
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
