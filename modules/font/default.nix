{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];
  
  options = {
    modules.font = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
  config = lib.mkIf config.modules.font.enable {
    home-manager.users = {
      "${builtins.toString config.modules.user.uid}" = {
        imports = [
          ./hm
        ];
      };
    };
  };
  
}
