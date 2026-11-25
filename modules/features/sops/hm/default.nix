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
  options = {
    features.sops = {
      enable = lib.mkEnableOption "Home Manager SOPS integration" // {
        apply =
          enable:
          assert lib.assertMsg (
            !enable || (osConfig.features.sops.enable or false)
          ) "Home Manager SOPS requires system SOPS.";
          enable;
      };
      secretsInput = lib.mkOption {
        type = llib.types.sopsSecretsInput;
        readOnly = true;
        description = "Per-user inputs consumed by the SOPS feature to generate Home Manager sops-nix secrets.";
      };

      defaultSopsFormat = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        readOnly = true;
        description = "Default format for generated secrets.";
      };
      defaultSopsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        readOnly = true;
        description = "Default encrypted file for generated secrets.";
      };
    };
  };

  config = lib.mkIf config.features.sops.enable {
    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = osConfig.features.sops.ageKeys.hm.path;
    };

    sops = lib.mkMerge [
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
          keyFile = osConfig.features.sops.ageKeys.hm.path;
          plugins = [ ];
          sshKeyPaths = [ ];
        };

        secrets = if hasDefaults then secrets.mkSopsSecrets cfg.secretsInput else { };
      }
      (lib.mkIf (cfg.defaultSopsFormat != null) { defaultSopsFormat = cfg.defaultSopsFormat; })
      (lib.mkIf (cfg.defaultSopsFile != null) { defaultSopsFile = cfg.defaultSopsFile; })
    ];

    assertions = [
      {
        assertion = cfg.secretsInput == [ ] || hasDefaults;
        message = "A non-empty features.sops.secretsInput requires defaultSopsFormat and defaultSopsFile.";
      }
    ];
  };
}
