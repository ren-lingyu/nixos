{ config, lib, pkgs, osConfig, ... } :  {
  
  imports = [
    ./top-level.nix
    ./input.nix
    ./outputs.nix
    ./layout.nix
    ./animations.nix
    ./window-rules.nix
    ./binds.nix
    ./noctalia-shell.nix
  ];

}
