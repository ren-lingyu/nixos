{ config, lib, pkgs, ... }:

{
  
  nix.settings.auto-optimise-store = true;
  
  boot.loader = {
    systemd-boot.configurationLimit = 10;
    # grub.configurationLimit = 10;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
