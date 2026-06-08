{ config, pkgs, lib, ... } : {
  
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];
  
}
