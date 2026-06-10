{ config, pkgs, lib, ... } : {
  
  options = {
    modules.hosts = {
      packageGroups = {
        tencent.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to install Tencent package group on this host.";
        };
      };
    };
  };
  
}
