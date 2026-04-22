{ config, lib, pkgs, osConfig, niri-flake, ... } :  {
  
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
