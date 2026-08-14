{ config, pkgs, lib, osConfig, llib, ... } : let

  cfg = osConfig.modules.features.sops;

  mif = config.moduleInterfaces.features.sops;

  lmf = llib.moduleFunctions.features.sops { inherit config; inherit osConfig; };

in {

  config = lib.mkIf cfg.enable {

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = osConfig.sops.secrets."age.keyFile".path;
    };

    sops = {

      defaultSopsFormat = mif.defaultSopsFormat;
      defaultSopsFile = mif.defaultSopsFile;
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

      secrets = lmf.mkSopsSecrets mif.secretsInput;

    };

  };

}
