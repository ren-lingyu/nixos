{ options, config, pkgs, lib, llib, ... } : {

  options = {

    modules.hosts = llib.moduleFunctions.default.mkModuleOptions.withoutExtra {
      path = ./.;
      commonSchema = (host_ : {

        identityKeys = lib.mkOption {
          type = lib.types.submodule {
            options = (lib.genAttrs
              [ "age" "ssh" ]
              (keyFormat_ : {

                public = {
                  key = lib.mkOption {
                    type = lib.types.nullOr lib.types.nonEmptyStr;
                    default = null;
                    description = "Public ${keyFormat_} key material for this host.";
                  };
                  ageRecipient = lib.mkOption {
                    type = lib.types.nullOr lib.types.nonEmptyStr;
                    default = null;
                    description = "Age recipient derived from the public ${keyFormat_} key for this host.";
                  };
                  path = lib.mkOption {
                    type = lib.types.nullOr lib.types.nonEmptyStr;
                    default = null;
                    description = "Runtime path of the public ${keyFormat_} key on this host.";
                  };
                };

                private = {
                  key = lib.mkOption {
                    type = lib.types.nullOr (lib.types.either lib.types.path lib.types.nonEmptyStr);
                    default = null;
                    description = (builtins.concatStringsSep
                      "\n"
                      [
                        "Private ${keyFormat_} key material for this host."
                        "Path values point to a repository file containing the key material; string values contain the key material inline."
                        "Stored private key material should be encrypted."
                      ]
                    );
                  };
                  path = lib.mkOption {
                    type = lib.types.nullOr lib.types.nonEmptyStr;
                    default = null;
                    description = "Runtime path of the private ${keyFormat_} key on this host.";
                  };
                };

              })
            );
          };
          internal = true;
          readOnly = true;
          example = {
            ssh = {
              public = {
                key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...";
                ageRecipient = "age1...";
                path = "/etc/ssh/ssh_host_ed25519_key.pub";
              };
              private.path = "/etc/ssh/ssh_host_ed25519_key";
            };
          };
          description = "Identity keys for this host, grouped by key format.";
        };

      });
    };

  };

}
