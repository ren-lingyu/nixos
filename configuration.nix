{ config, lib, pkgs, ... }:

{
  
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "@wheel" "root" ];
  };
  
  environment = {
    systemPackages = with pkgs; [
      git
      curl
    ];
  };
  
}
