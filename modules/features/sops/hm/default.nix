{ options, config, pkgs, lib, osConfig, llib, ... } : let

  cfg = osConfig.modules.features.sops;

  mif = config.moduleInterfaces.features.sops;

  mifOptions_ = options.moduleInterfaces.features.sops;

  secretsInput_ =
    if mifOptions_.secretsInput.isDefined
    then mif.secretsInput
    else [];

  lmf = llib.moduleFunctions.features.sops { inherit config; inherit osConfig; };

in {

  config = lib.mkIf cfg.enable {

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = cfg.ageKeys.hm.path;
    };

    sops = lib.mergeAttrsList [
      {

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
          keyFile = cfg.ageKeys.hm.path;
          plugins = [];
          sshKeyPaths = [];
        };

        secrets = lmf.mkSopsSecrets secretsInput_;

      }
      (lib.optionalAttrs mifOptions_.defaultSopsFormat.isDefined {
        defaultSopsFormat = mif.defaultSopsFormat;
      })
      (lib.optionalAttrs mifOptions_.defaultSopsFile.isDefined {
        defaultSopsFile = mif.defaultSopsFile;
      })
    ];

    assertions = [
      {
        assertion = (builtins.any
          (x_ : x_)
          [
            ((builtins.length secretsInput_) == 0)
            (builtins.all
              (x_ : x_)
              [
                mifOptions_.defaultSopsFormat.isDefined
                mifOptions_.defaultSopsFile.isDefined
              ]
            )
          ]
        );
        message = "A non-empty `moduleInterfaces.features.sops.secretsInput` requires `defaultSopsFormat` and `defaultSopsFile` to be defined.";
      }
    ];

  };

}
