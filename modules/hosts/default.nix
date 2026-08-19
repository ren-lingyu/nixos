{ options, config, pkgs, lib, llib, ... } : let

  cfg = config.modules.hosts;

  hostList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : (builtins.all
    (x_ : x_)
    [
      (type_ == "directory")
      (builtins.pathExists (./. + "/${name_}/default.nix"))
    ]
  )) (builtins.readDir ./.));

  enabledHost_ = llib.moduleFunctions.hosts.default.getUniqueEnabledHost config.modules.hosts;

in {

  options = {
    modules.hosts = (builtins.listToAttrs (builtins.map (host_ : {
      name = host_;
      value = let
        possibleExtraOptionsPath_ = ./. + "/${builtins.toString host_}/extra-options.nix";
      in lib.mergeAttrsList [
        {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = "Whether to enable this host profile.";
          };
          number = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.positive;
            internal = true;
            readOnly = true;
            example = 1;
            description = "Stable number assigned to this host.";
          };
          users = lib.mkOption {
            type = lib.types.attrsOf (lib.types.unique {
              message = "Each `modules.hosts.${host_}.users.<uid>` can only be defined once.";
            } lib.types.ints.unsigned);
            internal = true;
            default = {};
            example = {
              "1000" = 1000;
            };
            description = "UID-keyed declarations of managed users registered for this host.";
          };
          monitors = lib.mkOption {
            type = lib.types.attrsOf (lib.types.unique {
              message = "Each `modules.hosts.${host_}.monitors.<name>` can only be defined once.";
            } llib.types.monitor);
            internal = true;
            default = {};
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
            description = "Monitor declarations for this host.";
          };
          publicIpAddress = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            internal = true;
            readOnly = true;
            example = "203.0.113.10";
            description = "Public IP address assigned to this host.";
          };
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
          identityKeys = lib.mkOption {
            type = lib.types.submodule {
              options = builtins.listToAttrs (builtins.map (keyFormat_ : {
                name = keyFormat_;
                value = lib.mkOption {
                  type = lib.types.submodule {
                    options = {
                      public = lib.mkOption {
                        type = lib.types.submodule {
                          options = {
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
                        };
                        default = {};
                        description = "Public ${keyFormat_} identity key metadata for this host.";
                      };
                      private = lib.mkOption {
                        type = lib.types.submodule {
                          options = {
                            key = lib.mkOption {
                              type = lib.types.nullOr (lib.types.either lib.types.path lib.types.nonEmptyStr);
                              default = null;
                              description = "Private ${keyFormat_} key material for this host. Path values point to a repository file containing the key material; string values contain the key material inline. Stored private key material should be encrypted.";
                            };
                            path = lib.mkOption {
                              type = lib.types.nullOr lib.types.nonEmptyStr;
                              default = null;
                              description = "Runtime path of the private ${keyFormat_} key on this host.";
                            };
                          };
                        };
                        default = {};
                        description = "Private ${keyFormat_} identity key metadata for this host.";
                      };
                    };
                  };
                };
              }) [ "age" "ssh" ]);
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
          existModule = lib.mkOption {
            type = llib.types.existModule {
              optionPath = "modules.hosts.${host_}.existModule";
            };
            internal = true;
            default = {};
            description = "Module availability declared by the ${host_} host profile.";
          };
        }
        (lib.optionalAttrs (builtins.pathExists possibleExtraOptionsPath_) (
          (import possibleExtraOptionsPath_) host_ {
            inherit options;
            inherit config;
            inherit pkgs;
            inherit lib;
            inherit llib;
          }
        ))
      ];
    }) hostList_));
  };

  config = {

    modules.hosts = (builtins.listToAttrs
      (builtins.map
        (host_ : {
          name = host_;
          value = let
            possibleMetadataPath_ = ./. + "/${builtins.toString host_}/metadata.nix";
          in (lib.optionalAttrs
            (builtins.pathExists possibleMetadataPath_)
            ((import possibleMetadataPath_)
              host_
              {
                inherit config;
                inherit pkgs;
                inherit lib;
                inherit llib;
              }
            )
          );
        })
        hostList_
      )
    );

    age.secrets = lib.mkIf (enabledHost_.wireguard != null) {
      wireguard = {
        rekeyFile = enabledHost_.wireguard.privateKey;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    assertions = let
      enabledHosts_ = lib.filterAttrs (unused_name_ : host_ : host_.enable) cfg;
      enabledHostNames_ = builtins.attrNames enabledHosts_;
    in (builtins.concatLists [
      [
        {
          assertion = (builtins.length enabledHostNames_) == 1;
          message = "Exactly one host in `modules.hosts` must set `enable = true`. Enabled hosts: ${builtins.concatStringsSep ", " enabledHostNames_}.";
        }
      ]
      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : llib.assertions.existModule {
        enable = host_.enable;
        value = host_.existModule;
        optionPath = "modules.hosts.${hostName_}.existModule";
        osModulePath = ./. + "/${hostName_}/os/default.nix";
        hmModulePath = ./. + "/${hostName_}/hm/default.nix";
        enabledMessage = "`modules.hosts.${hostName_}.enable = true` requires the host profile to declare `existModule.os` and `existModule.hm`.";
      }) cfg))
      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : (builtins.concatLists [
        (let
          monitors_ = builtins.attrValues host_.monitors;
          defaultMonitors_ = builtins.filter (monitor_ : monitor_.role == "default") monitors_;
          monitorNames_ = builtins.map (monitor_ : monitor_.name) monitors_;
        in [
          {
            assertion = (builtins.length defaultMonitors_) <= 1;
            message = "At most one monitor in `modules.hosts.${hostName_}.monitors` may set `role = \"default\"`.";
          }
          {
            assertion = (builtins.length monitorNames_) == (builtins.length (lib.unique monitorNames_));
            message = "Monitor names in `modules.hosts.${hostName_}.monitors` must be unique.";
          }
        ])
        (builtins.concatLists (lib.mapAttrsToList (uidKey_ : uid_ : [
          {
            assertion = builtins.match "^[0-9]+$" uidKey_ != null;
            message = "`modules.hosts.${hostName_}.users.${uidKey_}` must use a numeric UID string as its attribute name, like `modules.hosts.${hostName_}.users.\"1000\"`.";
          }
          {
            assertion = (builtins.all
              (x_ : x_)
              [
                (builtins.match "^[0-9]+$" uidKey_ != null)
                (uidKey_ == builtins.toString uid_)
              ]
            );
            message = "`modules.hosts.${hostName_}.users.${uidKey_}` must use the canonical decimal representation of UID ${builtins.toString uid_}.";
          }
        ]) host_.users))
      ])) cfg))
    ]);

    home-manager.sharedModules = builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ :
      lib.optionals (builtins.all
        (x_ : x_)
        [
          host_.enable
          (host_.existModule.hm == true)
        ]
      ) [
        (./. + "/${hostName_}/hm")
      ]
    ) cfg);

  };

}
