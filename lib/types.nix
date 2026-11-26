{ lib }: rec {
  monitor = import ./monitor-type.nix { inherit lib; };
  monitors = lib.types.attrsOf monitor;

  identity = lib.types.submodule {
    options.keys = lib.mkOption {
      type = lib.types.submodule {
        options = {
          age = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  public = {
                    key = lib.mkOption {
                      type = lib.types.nullOr lib.types.nonEmptyStr;
                      default = null;
                      description = "Public age key material.";
                    };
                    path = lib.mkOption {
                      type = lib.types.nullOr lib.types.nonEmptyStr;
                      default = null;
                      description = "Runtime path of the public age key.";
                    };
                  };
                  private = {
                    key = lib.mkOption {
                      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.nonEmptyStr);
                      default = null;
                      description = builtins.concatStringsSep "\n" [
                        "Private age key material."
                        "Path values point to a repository file; string values contain key material inline."
                        "Stored private key material should be encrypted."
                      ];
                    };
                    path = lib.mkOption {
                      type = lib.types.nullOr lib.types.nonEmptyStr;
                      default = null;
                      description = "Runtime path of the private age key.";
                    };
                  };
                };
              }
            );
            default = null;
            description = "Age identity.";
          };

          ssh = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  public = {
                    key = lib.mkOption {
                      type = lib.types.nullOr lib.types.nonEmptyStr;
                      default = null;
                      description = "Public ssh key material.";
                    };
                    ageRecipient = lib.mkOption {
                      type = lib.types.nullOr lib.types.nonEmptyStr;
                      default = null;
                      description = "Age recipient derived from the SSH public key.";
                    };
                    path = lib.mkOption {
                      type = lib.types.nullOr lib.types.nonEmptyStr;
                      default = null;
                      description = "Runtime path of the public ssh key.";
                    };
                  };
                  private = {
                    key = lib.mkOption {
                      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.nonEmptyStr);
                      default = null;
                      description = builtins.concatStringsSep "\n" [
                        "Private ssh key material."
                        "Path values point to a repository file; string values contain key material inline."
                        "Stored private key material should be encrypted."
                      ];
                    };
                    path = lib.mkOption {
                      type = lib.types.nullOr lib.types.nonEmptyStr;
                      default = null;
                      description = "Runtime path of the private ssh key.";
                    };
                  };
                };
              }
            );
            default = null;
            description = "SSH identity.";
          };
        };
      };
      default = { };
      description = "Identity keys grouped by key format.";
    };
  };

  deferredModuleFragment = lib.types.mkOptionType {
    name = "deferredModuleFragment";
    description = "Deferred function producing a module fragment.";
    check = value: lib.isFunction value || builtins.isAttrs value;
    merge =
      loc: defs:
      let
        value = lib.options.mergeOneOption loc defs;
      in
      if lib.isFunction value then value else _: value;
  };

  defaultEditor = lib.types.nullOr (
    lib.types.enum [
      "vim"
      "neovim"
      "emacs"
    ]
  );

  sopsSecretsInput = lib.types.listOf (
    lib.types.submodule {
      options = {
        template = lib.mkOption {
          type = lib.types.enum [ "user" ];
          default = "user";
          description = "Secret template used to generate paths and ownership for this Home Manager user.";
        };
        structure = lib.mkOption {
          type = lib.types.attrsOf (
            lib.fix (
              self:
              lib.mergeAttrsList [
                (lib.types.either (lib.types.nonEmptyListOf lib.types.nonEmptyStr) (lib.types.attrsOf self))
                { description = "a non-empty list of strings or a nested attribute set"; }
              ]
            )
          );
          default = { };
          description = "Nested secret-key structure converted into individual sops-nix secret declarations.";
        };
      };
    }
  );
}
