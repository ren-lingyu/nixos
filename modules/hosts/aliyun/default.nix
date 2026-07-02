{ config, pkgs, lib, ... } : {
  
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];
  
  config = {
    modules.hosts.aliyun.enable = true;
  };
  
}
