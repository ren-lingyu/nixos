{
  config,
  lib,
  llib,
  ...
}@args:
let
  cfg = config.features.sops;
  osConfig = args.osConfig or { };
  secrets = import ./secrets.nix { inherit config; };
  hasDefaults = cfg.defaultSopsFormat != null && cfg.defaultSopsFile != null;
in
{
  options.features.sops = {
    enable = lib.mkEnableOption "Home Manager SOPS integration";
    secretsInput = lib.mkOption {
      type = llib.types.sopsSecretsInput;
      default = [ ];
      description = "Per-user inputs consumed by the SOPS feature to generate Home Manager sops-nix secrets.";
    };

    defaultSopsFormat = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default format for generated secrets.";
    };
    defaultSopsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Default encrypted file for generated secrets.";
    };
    ageKeyPath = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path of the shared SOPS age key.";
    };
  };

  config = lib.mkIf config.features.sops.enable {
    features.sops.ageKeyPath = lib.mkIf (osConfig.features.sops.enable or false) (
      lib.mkDefault osConfig.age.secrets."sops.hm".path
    );

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = cfg.ageKeyPath;
    };

    sops = lib.mergeAttrsList [
      {
        defaultSopsKey = null;
        keepGenerations = 1;
        validateSopsFiles = true;
        environment = { };

        log = [
          "keyImport"
          "secretChanges"
        ];

        age = {
          generateKey = false;
          keyFile = cfg.ageKeyPath;
          plugins = [ ];
          sshKeyPaths = [ ];
        };

        secrets = if hasDefaults then secrets.mkSopsSecrets cfg.secretsInput else { };
      }
      (lib.optionalAttrs (cfg.defaultSopsFormat != null) { defaultSopsFormat = cfg.defaultSopsFormat; })
      (lib.optionalAttrs (cfg.defaultSopsFile != null) { defaultSopsFile = cfg.defaultSopsFile; })
    ];

    assertions = [
      {
        assertion = cfg.secretsInput == [ ] || hasDefaults;
        message = "A non-empty features.sops.secretsInput requires defaultSopsFormat and defaultSopsFile.";
      }
    ];
  };
}
