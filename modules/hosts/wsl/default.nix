{ config, pkgs, lib, ... } : {
  
  imports = [
    ./configuration.nix
  ];
  
  config = {
    modules.hosts.wsl.enable = true;
  };
  
}
