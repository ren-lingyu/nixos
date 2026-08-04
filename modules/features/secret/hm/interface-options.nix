feature_ : { options, config, osConfig, pkgs, lib, llib, ... } : {

  sops = {

    secretsInput = lib.mkOption {
      type = lib.types.unique {
        message = "Conflicting definitions for `moduleInterfaces.features.${feature_}.sopsSecretsInput`.";
      } (lib.types.listOf (lib.types.submodule {
        options = {
          template = lib.mkOption {
            type = lib.types.enum [
              "user"
            ];
            default = "user";
            description = "Secret template used to generate paths and ownership for this Home Manager user.";
          };
          structure = lib.mkOption {
            type = lib.types.attrsOf (
              lib.fix (self : (lib.types.either
                (lib.types.nonEmptyListOf lib.types.nonEmptyStr)
                (lib.types.attrsOf self)
              ) // {
                description = "a non-empty list of strings or a nested attribute set";
              })
            );
            default = {};
            description = "Nested secret-key structure converted into individual sops-nix secret declarations.";
          };
        };
      }));
      default = [];
      internal = true;
      description = "Per-user inputs consumed by the ${feature_} feature to generate Home Manager sops-nix secrets.";
    };

    defaultSopsFormat = lib.mkOption {
      type = lib.types.unique {
        message = "Conflicting definitions for `moduleInterfaces.features.${feature_}.defaultSopsFormat`.";
      } lib.types.str;
      default = "yaml";
      internal = true;
      description = "Default SOPS format used by the ${feature_} feature for this Home Manager user.";
    };

    defaultSopsFile = lib.mkOption {
      type = lib.types.unique {
        message = "Conflicting definitions for `moduleInterfaces.features.${feature_}.defaultSopsFile`.";
      } lib.types.path;
      internal = true;
      description = "Encrypted SOPS file containing secrets for this Home Manager user.";
    };

  };

}
