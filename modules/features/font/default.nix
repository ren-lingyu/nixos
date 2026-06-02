{ config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];
  
  options = {
    modules.features.font = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
  config = lib.mkIf config.modules.features.font.enable {
    home-manager.users = {
      "${builtins.toString config.modules.users.uid}" = {
        imports = [
          ./hm
        ];
      };
    };
  };
  
}
