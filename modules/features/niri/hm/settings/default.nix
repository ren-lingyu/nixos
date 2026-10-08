{ config, osConfig, pkgs, lib, ... } :  {

  imports = [
    ./top-level.nix
    ./input.nix
    ./outputs.nix
    ./layout.nix
    ./animations.nix
    ./window-rules.nix
    ./binds.nix
    ./noctalia.nix
  ];

}
