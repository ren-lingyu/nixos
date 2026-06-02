{ config, pkgs, lib, ... } : {
  
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./mount-windows-directory.nix
    ./virtual-terminal.nix
    ./boot-manager.nix
    ./flatpak.nix
  ];
  
}
