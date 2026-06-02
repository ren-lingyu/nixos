{ config, pkgs, lib, ... } : {
  
  options = {
    modules = {
      user = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
        };
        name = lib.mkOption {
          type = lib.types.str;
          example = "nixos";
        };
        uid = lib.mkOption {
          type = lib.types.ints.unsigned;
          example = 1000;
        };
        home = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          example = "/home/jane.doe";
        };
      };
    };
  };
  
  config = lib.mkMerge [

    {
      assertions = let cfg = config.modules.user; in [
        {
          assertion = !cfg.enable || cfg.name != "";
          message = "`modules.user.name` must not be empty.";
        }
        {
          assertion = !cfg.enable || cfg.uid >= 1000;
          message = "`modules.user.uid` must be greater than or equal to 1000 for a normal user.";
        }
        {
          assertion = !cfg.enable || lib.hasPrefix "/" cfg.home;
          message = "`modules.user.home` must be an absolute path.";
        }
      ];
    }
    
    (lib.mkIf config.modules.user.enable {
      
      users.users = {
        "${builtins.toString config.modules.user.uid}" = {
          name = lib.mkForce config.modules.user.name;
          home = lib.mkForce config.modules.user.home;
        };
      };
      
      home-manager.users = {
        "${builtins.toString config.modules.user.uid}" = {
          imports = [
            ./lingyu
          ];
          home = {
            uid = config.modules.user.uid;
            username = config.modules.user.name;
            homeDirectory = config.modules.user.home;
          };
        };
      };
    })
    
  ];
  
}
