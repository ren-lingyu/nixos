{ config, pkgs, lib, ... } : {

  imports = [
    ./configuration.nix
  ];

  config = {
    modules.hosts.wsl = {
      enable = true;
      users = {
        "1000" = 1000;
      };
    };
  };

}
