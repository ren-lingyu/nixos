{ options, config, pkgs, lib, llib, ... } : let

  cfg = config.modules.hosts;

  mif = llib.moduleFunctions.hosts.default;

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

in {

  options = {

    modules.hosts = llib.moduleFunctions.default.mkModuleOptions.withoutExtra {
      path = ./.;
      commonSchema = (host_ : {

        wireguard = lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule {
            options = {

              publicKey = lib.mkOption {
                type = lib.types.nonEmptyStr;
                description = "WireGuard public key for this host.";
              };

              privateKey = lib.mkOption {
                type = (lib.types.either
                  lib.types.path
                  lib.types.nonEmptyStr
                );
                description = (builtins.concatStringsSep
                  "\n"
                  [
                    "WireGuard private key material for this host."
                    "Path values point to a repository file containing the key material; string values contain the key material inline."
                    "Stored private key material should be encrypted."
                  ]
                );
              };

              listenPort = lib.mkOption {
                type = lib.types.nullOr lib.types.port;
                default = null;
                description = "Local UDP port on which WireGuard listens on this host.";
              };

              endpoint = lib.mkOption {
                type = lib.types.nullOr (lib.types.submodule {
                  options = {
                    address = lib.mkOption {
                      type = lib.types.nonEmptyStr;
                      description = "Reachable address of this WireGuard endpoint.";
                    };
                    port = lib.mkOption {
                      type = lib.types.port;
                      description = "Reachable UDP port of this WireGuard endpoint.";
                    };
                  };
                });
                default = null;
                description = "WireGuard endpoint through which this host can be reached by other hosts.";
              };

            };
          });
          internal = true;
          readOnly = true;
          description = "Static WireGuard metadata for this host.";
        };

      });
    };

  };

  config = {

    age.secrets = lib.mkIf (enabledHost_.wireguard != null) {
      wireguard = {
        rekeyFile = enabledHost_.wireguard.privateKey;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    networking = mif.mkWireGuardNetworking {
      registry = cfg;
      privateKeyFile = config.age.secrets.wireguard.path;
      wgIpRule = (x_ : y_ : "10.100.${builtins.toString x_}.${builtins.toString y_}");
      wgNameRule = (x_ : "wg${builtins.toString x_}");
    };

    assertions = (lib.mapAttrsToList
      (hostName_ : host_ : {
        assertion = (builtins.any
          (x_ : x_)
          [
            (host_.wireguard == null)
            (host_.wireguard.endpoint == null)
            (host_.wireguard.listenPort != null)
          ]
        );
        message = "Host `${hostName_}` with a WireGuard endpoint must provide `wireguard.listenPort`.";
      })
      cfg
    );

  };

}
