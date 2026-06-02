{ config, lib, pkgs, ... } : {
  
  options = {
    modules.agent = {
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
          assertion = !config.modules.agent.enable || config.modules.secret.enable;
          message = "This modules should be used while the sops-nix is enbaled";
        }
      ];
    }
    
    (lib.mkIf config.modules.agent.enable {
      
      home-manager.users = {
        "${builtins.toString config.modules.user.uid}" = {
          imports = [
            ./hm
          ];
        };
      };
      
    })
  ];

}
