{ config, lib, pkgs, ... } : {

  imports = [
    ./os
  ];
  
  options = {
    modules.secret = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
      os.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.modules.secret.enable;
        example = true;
      };
      hm.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.modules.secret.enable;
        example = true;
      };
    };
  };

  config = lib.mkMerge [
    
    {
      assertions = [
        {
          assertion = !config.modules.secret.os.enable || config.modules.secret.enable;
          message = "The greeter of niri should be used only when niri is enabled.";
        }
        {
          assertion = !config.modules.secret.hm.enable || config.modules.secret.enable;
          message = "The greeter of niri should be used only when niri is enabled.";
        }
      ];
    }
    
    (lib.mkIf (config.modules.secret.enable && config.modules.secret.hm.enable) {
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
