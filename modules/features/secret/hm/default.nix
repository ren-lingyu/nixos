{ config, pkgs, lib, osConfig, llib, ... } : let

  cfg = osConfig.modules.features.secret;

  itf = config.moduleInterfaces.features.secret;

  lmf = llib.moduleFunctions.features.secret { inherit config; inherit osConfig; };

in {

  config = lib.mkIf cfg.enable {

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = osConfig.sops.secrets."age.keyFile".path;
    };

    sops = {

      defaultSopsFormat = itf.sops.defaultSopsFormat;
      defaultSopsFile = itf.sops.defaultSopsFile;
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

      secrets = lmf.mkSopsSecrets itf.sops.secretsInput;

    };

  };

}
