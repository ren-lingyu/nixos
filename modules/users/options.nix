{ lib, llib, ... }: {
  options.nixosBuilderArgs.userRegistry = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          sops = {
            defaultSopsFormat = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            defaultSopsFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
            };
            secretsInput = lib.mkOption {
              type = llib.types.sopsSecretsInput;
              default = [ ];
            };
          };
          agent.pi.apiKeySecrets = lib.mkOption {
            type = lib.types.attrsOf lib.types.nonEmptyStr;
            default = { };
            description = "Mapping from Pi provider names to SOPS secret names.";
          };
        };
      }
    );
  };

  options.nixosConfigurations = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }: {
          config.features.sops.module.features.sops.authorizedUids = lib.mapAttrsToList (
            uid: _: builtins.fromJSON uid
          ) (lib.filterAttrs (_: account: account.features.sops.enable) config.users);

          options.users = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                { config, ... }:
                let
                  account = config;
                in
                {
                  config.features = {
                    sops.module.features.sops = config.profile.sops;
                    agent.module = { config, ... }: {
                      features.agent.pi.providers = lib.mkIf (config.features.sops.enable or false) (
                        lib.mapAttrs (_: secret: {
                          enable = true;
                          apiKeyFile = config.sops.secrets.${secret}.path;
                        }) account.profile.agent.pi.apiKeySecrets
                      );
                    };
                  };
                }
              )
            );
          };
        }
      )
    );
  };
}
