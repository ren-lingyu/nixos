{ config, pkgs, lib, osConfig, ... } : let
  llib = import ../lib { inherit config; inherit osConfig; };
in {

  config = lib.mkIf osConfig.modules.features.secret.enable {

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = osConfig.sops.secrets."age.keyFile".path;
    };

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
            "alibabacloud" = {
              "oss" = [ "access_key_id" "secret_access_key" ];
            };
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
            "modelscope" = {
              "apiKey" = [ "opencode" ];
            };
          };
        }
      ];
      
    };
    
  };
  
}
