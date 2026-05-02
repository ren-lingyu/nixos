{ config, pkgs, lib, ... } : let
  llib = import ./lib.nix { inherit config; };
in {

  config = {
    
    environment.systemPackages = with pkgs; [
      age
      sops
      ssh-to-age
      ssh-to-pgp
    ];

    sops = {
      
      defaultSopsFormat = "yaml";
      defaultSopsFile = ./sops/default.yaml;
      defaultSopsKey = null;
      keepGenerations = 1;
      validateSopsFiles = true;
      environment = {};

      log = [
        "keyImport"
        "secretChanges"
      ];
      
      age = {
        generateKey = false;
        keyFile = null;
        plugins = [];
        sshKeyPaths = lib.optionals config.services.openssh.enable (
          map (hostKeys: hostKeys.path) (
            lib.filter (hostKeys: hostKeys.type == "ed25519") config.services.openssh.hostKeys
          )
        );
      };
      
      secrets = llib.mkSopsSecrets [
        {
          template = "system";
          structure = {
            age = [ "keyFile" ];
          };
          overlay = {
            uid = 1000;
            gid = 100;
          };
        }
      ];
      
    };
    
  };
  
}
