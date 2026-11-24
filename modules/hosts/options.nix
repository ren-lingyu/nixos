{
  config,
  lib,
  llib,
  ...
}:
{
  options.nixosBuilderArgs.hostRegistry = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }: {
          options = {
            number = lib.mkOption {
              type = lib.types.ints.positive;
              internal = true;
              readOnly = true;
              example = 1;
              description = "Stable number assigned to this host.";
            };

            users = lib.mkOption {
              type = lib.types.attrsOf (
                lib.types.unique {
                  message = "Each `nixosBuilderArgs.hostRegistry.${name}.users.<uid>` may only be defined once.";
                } lib.types.ints.unsigned
              );
              internal = true;
              default = { };
              example = {
                "1000" = 1000;
              };
              apply =
                users:
                assert lib.assertMsg (builtins.all (valid: valid) (
                  lib.mapAttrsToList (key: uid: key == builtins.toString uid) users
                )) "Host `${name}` UID registry keys must be canonical decimal representations of their values.";
                users;
              description = "UID-keyed declarations of managed users registered for this host.";
            };

            monitors = lib.mkOption {
              type = lib.types.attrsOf (
                lib.types.unique {
                  message = "Each `nixosBuilderArgs.hostRegistry.${name}.monitors.<name>` may only be defined once.";
                } llib.types.monitor
              );
              internal = true;
              default = { };
              example = {
                "eDP-1" = {
                  name = "eDP-1";
                  role = "default";
                  mode = {
                    width = 3072;
                    height = 1920;
                    refresh = 60.0;
                  };
                  scale = 1.6;
                };
              };
              apply =
                monitors:
                let
                  values = builtins.attrValues monitors;
                  names = builtins.map (monitor: monitor.name) values;
                in
                assert lib.assertMsg (
                  lib.count (monitor: monitor.role == "default") values <= 1
                ) "At most one monitor in Host `${name}` may have role = default.";
                assert lib.assertMsg (
                  builtins.length names == builtins.length (lib.unique names)
                ) "Monitor names in Host `${name}` must be unique.";
                assert lib.assertMsg (builtins.all (
                  monitor: monitor.role != "default" || monitor.mode != null
                ) values) "Default monitors in Host `${name}` must provide a non-null mode.";
                monitors;
              description = "Monitor declarations for this host.";
            };

            publicIpAddress = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              internal = true;
              readOnly = true;
              example = "203.0.113.10";
              description = "Public IP address assigned to this host.";
            };

            bootManager = lib.mkOption {
              type = lib.types.submodule {
                options.enable = lib.mkOption {
                  type = lib.types.bool;
                  internal = true;
                  readOnly = true;
                  description = "Whether to apply the boot-manager template for this host.";
                };
              };
              default = { };
              description = "Boot-manager template configuration for the ${name} host.";
            };

            identity = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  rootAccess = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "Whether this host has direct access to the root identity.";
                  };
                  keys = lib.mkOption {
                    type = lib.types.submodule {
                      options = lib.genAttrs [ "age" "ssh" ] (keyFormat_: {
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
                            description = builtins.concatStringsSep "\n" [
                              "Private ${keyFormat_} key material for this host."
                              "Path values point to a repository file containing the key material; string values contain the key material inline."
                              "Stored private key material should be encrypted."
                            ];
                          };
                          path = lib.mkOption {
                            type = lib.types.nullOr lib.types.nonEmptyStr;
                            default = null;
                            description = "Runtime path of the private ${keyFormat_} key on this host.";
                          };
                        };
                      });
                    };
                    description = "Identity keys for this host, grouped by key format.";
                  };
                };
              };
              internal = true;
              readOnly = true;
              example = {
                keys.ssh = {
                  public = {
                    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...";
                    ageRecipient = "age1...";
                    path = "/etc/ssh/ssh_host_ed25519_key.pub";
                  };
                  private.path = "/etc/ssh/ssh_host_ed25519_key";
                };
                rootAccess = true;
              };
              description = "Identity configuration for this host.";
            };

            shared = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  networkmanager.enable = lib.mkOption {
                    type = lib.types.bool;
                    internal = true;
                    readOnly = true;
                    description = "Whether to enable NetworkManager for this host.";
                  };
                  bluetooth.enable = lib.mkOption {
                    type = lib.types.bool;
                    internal = true;
                    readOnly = true;
                    description = "Whether to enable Bluetooth and blueman for this host.";
                  };
                  power.enable = lib.mkOption {
                    type = lib.types.bool;
                    internal = true;
                    readOnly = true;
                    description = "Whether to enable power-profiles-daemon and UPower for this host.";
                  };
                };
              };
              default = { };
              description = "Shared system services for the ${name} host.";
            };

            wireguard = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.submodule {
                  options = {
                    publicKey = lib.mkOption {
                      type = lib.types.nonEmptyStr;
                      description = "WireGuard public key for this host.";
                    };
                    privateKey = lib.mkOption {
                      type = lib.types.either lib.types.path lib.types.nonEmptyStr;
                      description = builtins.concatStringsSep "\n" [
                        "WireGuard private key material for this host."
                        "Path values point to a repository file containing the key material; string values contain the key material inline."
                        "Stored private key material should be encrypted."
                      ];
                    };
                    listenPort = lib.mkOption {
                      type = lib.types.nullOr lib.types.port;
                      default = null;
                      description = "Local UDP port on which WireGuard listens on this host.";
                    };
                    endpoint = lib.mkOption {
                      type = lib.types.nullOr (
                        lib.types.submodule {
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
                        }
                      );
                      default = null;
                      description = "WireGuard endpoint through which this host can be reached by other hosts.";
                    };
                  };
                }
              );
              internal = true;
              readOnly = true;
              apply =
                wireguard:
                assert lib.assertMsg (
                  wireguard == null || wireguard.endpoint == null || wireguard.listenPort != null
                ) "Host `${name}` with a WireGuard endpoint must provide wireguard.listenPort.";
                wireguard;
              description = "Static WireGuard configuration for this host.";
            };
          };
        }
      )
    );
    apply =
      hosts:
      let
        numbers = builtins.map (host: host.number) (builtins.attrValues hosts);
      in
      assert builtins.deepSeq numbers (
        lib.assertMsg (
          builtins.length numbers == builtins.length (lib.unique numbers)
        ) "Host numbers must be globally unique."
      );
      hosts;
  };

  config.nixosBuilderArgs.hostTopology = llib.hosts.mkWireGuardTopology {
    registry = config.nixosBuilderArgs.hostRegistry;
  };
}
