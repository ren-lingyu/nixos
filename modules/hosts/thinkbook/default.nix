{ config, pkgs, lib, ... } : {
  
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./mount-windows-directory.nix
    ./virtual-terminal.nix
    ./boot-manager.nix
    ./flatpak.nix
  ];
  
  config = {
    modules.hosts = {
      monitors = {
        "eDP-1" = {
          name = "eDP-1";
          role = "default";
          width = 3072;
          height = 1920;
          refresh = 60.0;
          scale = 1.6;
        };
        "HDMI-A-1" = {
          name = "HDMI-A-1";
          role = null;
          width = null;
          height = null;
          refresh = null;
          scale = 1.0;
        };
      };
    };
  };
  
}
