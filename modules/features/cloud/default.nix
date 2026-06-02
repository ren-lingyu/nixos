{ config, lib, pkgs, ... } : {

  options = {
    modules.features.cloud = {
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
          assertion = !config.modules.features.cloud.enable || config.modules.features.secret.enable;
          message = "This modules should be used while the sops-nix is enbaled";
        }      
      ];
    }
    
    (lib.mkIf config.modules.features.cloud.enable {
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
