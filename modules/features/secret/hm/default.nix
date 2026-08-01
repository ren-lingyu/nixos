{ config, pkgs, lib, osConfig, ... } : let

  cfg = osConfig.modules.features.secret;

  llib = import ../lib { inherit config; inherit osConfig; };

in {

  config = lib.mkIf cfg.enable {

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = osConfig.sops.secrets."age.keyFile".path;
    };

    sops = {

      defaultSopsFormat = config.moduleInterfaces.features.secret.defaultSopsFormat;
      defaultSopsFile = config.moduleInterfaces.features.secret.defaultSopsFile;
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

      secrets = llib.mkSopsSecrets config.moduleInterfaces.features.secret.sopsSecretsInput;

    };

  };

}
