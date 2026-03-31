{ config, lib, pkgs, ... }:

{
  
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "@wheel" "root" ];
    auto-optimise-store = true;
  };
  
  environment = {
    systemPackages = with pkgs; [
      git
      curl
    ];
  };
  
}
