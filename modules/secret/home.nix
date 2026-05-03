{ config, pkgs, lib, osConfig, ... } : let
  llib = import ./lib.nix { inherit config; inherit osConfig; };
in {

  config = {

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
        keyFile = osConfig.sops.secrets."age.keyFile".path;
        plugins = [];
        sshKeyPaths = [];
      };
      
      secrets = llib.mkSopsSecrets [
        {
          template = "user";
          structure = {
            "nutstore" = [ "user" "pass" ];
            "123cloud" = [ "user" "pass" ];
            "cloudflare" = [ "access_key_id" "secret_access_key" "endpoint" ];
            "onedrive" = [ "token" "drive_id" ];
          };
        }
        {
          template = "user";
          structure = {
            "deepseek" = {
              "apiKey" = [ "opencode" ];
            };
            "ollama" = {
              "apiKey" = [ "opencode" ];
            };
          };
        }
      ];
      
    };
    
  };
  
}
