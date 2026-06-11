{ config, lib, pkgs, ... } : {

  imports = [
    ./home.nix
    ./terminal.nix
    ./keyring.nix
    ./git.nix
    ./langs.nix
    ./email.nix
    ./cloud-server.nix
  ];

}
