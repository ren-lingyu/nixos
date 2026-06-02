{ config, pkgs, lib, ... } : {
  
  options = {
    modules = {
      users = {
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
      assertions = let cfg = config.modules.users; in [
        {
          assertion = !cfg.enable || cfg.name != "";
          message = "`modules.users.name` must not be empty.";
        }
        {
          assertion = !cfg.enable || cfg.uid >= 1000;
          message = "`modules.users.uid` must be greater than or equal to 1000 for a normal user.";
        }
        {
          assertion = !cfg.enable || lib.hasPrefix "/" cfg.home;
          message = "`modules.users.home` must be an absolute path.";
        }
      ];
    }
    
    (lib.mkIf config.modules.users.enable {
      
      users.users = {
        "${builtins.toString config.modules.users.uid}" = {
          name = lib.mkForce config.modules.users.name;
          home = lib.mkForce config.modules.users.home;
        };
      };
      
      home-manager.users = {
        "${builtins.toString config.modules.users.uid}" = {
          imports = [
            ./lingyu
          ];
          home = {
            uid = config.modules.users.uid;
            username = config.modules.users.name;
            homeDirectory = config.modules.users.home;
          };
        };
      };
    })
    
  ];
  
}
