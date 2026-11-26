{
  lib,
  runCommand,
  flakeParts,
  hosts,
  types,
  identity,
  modules,
}:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    deferredModule
    listOf
    str
    ;

  markers = mkOption {
    type = listOf str;
    default = [ ];
  };

  osFixture = {
    options = {
      inherit markers;
      accountMetadata = mkOption { type = lib.types.raw; };
      age.secrets = mkOption {
        type = attrsOf lib.types.anything;
        default = { };
      };
      environment.systemPackages = mkOption {
        type = listOf lib.types.package;
        default = [ ];
      };
      services.pcscd.enable = lib.mkEnableOption "PC/SC fixture";
      users.users = mkOption {
        type = attrsOf (
          lib.types.submodule {
            options = {
              uid = mkOption { type = lib.types.int; };
              name = mkOption { type = str; };
              home = mkOption { type = str; };
              createHome = mkOption { type = lib.types.bool; };
              isNormalUser = mkOption { type = lib.types.bool; };
            };
          }
        );
        default = { };
      };
      home-manager = {
        users = mkOption {
          type = attrsOf deferredModule;
          default = { };
        };
        sharedModules = mkOption {
          type = listOf deferredModule;
          default = [ ];
        };
        extraSpecialArgs = mkOption {
          type = attrsOf lib.types.raw;
          default = { };
        };
      };
      features.alpha.enable = lib.mkEnableOption "OS alpha";
      workloads.service.enable = lib.mkEnableOption "workload";
    };
  };

  hmFixture = {
    options = {
      inherit markers;
      home = {
        uid = mkOption { type = lib.types.int; };
        username = mkOption { type = str; };
        homeDirectory = mkOption { type = str; };
      };
      features.alpha = {
        enable = lib.mkEnableOption "HM alpha";
        profileUid = mkOption { type = lib.types.int; };
        inputs = mkOption {
          type = listOf str;
          default = [ ];
        };
      };
    };
    config._module.args.customArg = "native-argument";
  };

  invalid = throw "An unselected deferred module must never be imported";

  hostData = {
    users = {
      "1000" = 1000;
      "1001" = 1001;
    };
    publicIpAddress = null;
    wireguard = null;
    identity = { };
  };

  evaluate =
    extra:
    (lib.evalModules {
      specialArgs.llib = { inherit hosts types; };
      modules = [
        (modules + "/hosts/options.nix")
        (modules + "/users/options.nix")
        ({ config, ... }: {
          options = flakeParts.mkOptions config // {
            test = {
              secondNumber = mkOption {
                type = lib.types.ints.positive;
                default = 2;
              };
              secondWireguard = mkOption {
                type = lib.types.nullOr lib.types.raw;
                default = null;
              };
            };
          };
          config = {
            nixosBuilderArgs = {
              nixosSystem = args: lib.evalModules { inherit (args) specialArgs modules; };
              homeManager = osFixture;
              baseModule = {
                imports = [
                  (modules + "/base/os/identity.nix")
                  ({ accounts, ... }: { accountMetadata = accounts; })
                ];
                markers = [ "base" ];
                home-manager.sharedModules = [ { markers = [ "shared" ]; } ];
              };
              specialArgs = {
                marker = "argument";
                llib = { inherit identity; };
                pkgs = { };
              };
              hostRegistry = {
                first = hostData // {
                  number = 1;
                  module =
                    {
                      host,
                      hostRegistry,
                      hostTopology,
                      ...
                    }:
                    {
                      markers = [
                        host.name
                        (toString hostRegistry.second.number)
                        (toString (builtins.length (lib.attrNames hostTopology)))
                      ];
                    };
                };
                second = hostData // {
                  number = config.test.secondNumber;
                  wireguard = config.test.secondWireguard;
                  module = {
                    imports = [ invalid ];
                  };
                };
              };
              userRegistry.noIdentity.identity = { };
              userRegistry.profile = {
                identity.keys.age = {
                  public.key = "age1-test";
                  private.key = ./test.nix;
                };
                module.markers = [ "profile" ];
                features = {
                  alpha.module =
                    lib.setFunctionArgs
                      (args: {
                        profileUid = args.config.home.uid;
                        inputs = args.lib.mkBefore [
                          args.marker
                          args.customArg
                        ];
                      })
                      {
                        config = false;
                        lib = false;
                        marker = false;
                        customArg = false;
                      };
                  absent.module = _: invalid;
                };
              };
              featureRegistry = {
                os = {
                  alpha = {
                    markers = [ "os-implementation" ];
                  };
                  absent = {
                    imports = [ invalid ];
                  };
                };
                hm = {
                  alpha = {
                    markers = [ "hm-implementation" ];
                  };
                  absent = {
                    imports = [ invalid ];
                  };
                };
              };
              workloadRegistry.service = {
                markers = [ "workload" ];
              };
            };
            nixosConfigurations.one = {
              host = config.nixosBuilderArgs.hostRegistry.first;
              features = {
                alpha.enable = true;
                alpha.module.markers = [ "os-consumer" ];
                absent.module.imports = [ invalid ];
              };
              workloads.service.enable = true;
              users = {
                "1000" = {
                  username = "first";
                  profile = config.nixosBuilderArgs.userRegistry.profile;
                  features.alpha.enable = true;
                  features.alpha.module = {
                    markers = [ "hm-consumer" ];
                    features.alpha.inputs = [ "consumer" ];
                  };
                };
                "1001" = {
                  username = "second";
                  profile = config.nixosBuilderArgs.userRegistry.profile;
                  features.absent.module.imports = [ invalid ];
                };
              };
            };
          };
        })
      ]
      ++ extra;
    }).config;

  construct =
    fp:
    flakeParts.mkNixosConfigurations {
      builderArgs = fp.nixosBuilderArgs;
      configurations = fp.nixosConfigurations;
    };

  os =
    (construct (evaluate [ { nixosConfigurations.one.features.alpha.module.markers = [ "merged" ]; } ]))
    .one.config;

  withoutIdentity =
    (construct (evaluate [
      ({ config, ... }: {
        nixosConfigurations.one.users."1001".profile =
          lib.mkForce config.nixosBuilderArgs.userRegistry.noIdentity;
      })
    ])).one.config;

  hmFor =
    system: uid:
    (lib.evalModules {
      modules = [
        hmFixture
        system.home-manager.users.${uid}
      ]
      ++ system.home-manager.sharedModules;
      specialArgs = system.home-manager.extraSpecialArgs;
    }).config;

  hm = hmFor os;

  reusedProfile =
    hmFor
      (construct (evaluate [ { nixosConfigurations.one.users."1001".features.alpha.enable = true; } ]))
      .one.config
      "1001";

  duplicateProfileModule =
    (evaluate [
      { nixosBuilderArgs.userRegistry.profile.features.alpha.module = lib.mkForce { profileUid = 1; }; }
    ]).nixosBuilderArgs.userRegistry.profile.features.alpha.module;

  disabled =
    (construct (evaluate [
      {
        nixosConfigurations.one.features.alpha.enable = lib.mkForce false;
        nixosConfigurations.one.workloads.service.enable = lib.mkForce false;
      }
    ])).one.config;

  fails = extra: !(builtins.tryEval (builtins.attrNames (construct (evaluate extra)))).success;

  failsHostOption =
    field: extra:
    !(builtins.tryEval (
      builtins.deepSeq (evaluate extra).nixosBuilderArgs.hostRegistry.second.${field} true
    )).success;

  # Local fields may read other registry entries after the registry-level number check.
  crossHostMonitors =
    (evaluate [
      ({ config, ... }: {
        nixosBuilderArgs.hostRegistry = {
          first.monitors.external = {
            role = null;
          };
          second.monitors = config.nixosBuilderArgs.hostRegistry.first.monitors;
        };
      })
    ]).nixosBuilderArgs.hostRegistry.second.monitors;

  # Exercise the real project FP schema extensions independently of the full NixOS/HM build.
  connected =
    (evaluate [
      (modules + "/features/greeter/default.nix")
      (modules + "/features/niri/default.nix")
      (modules + "/features/sops/default.nix")
      {
        nixosBuilderArgs = {
          featureRegistry.hm.agent = { };
          hostRegistry.first.monitors."eDP-1" = {
            role = "default";
            mode = {
              width = 1920;
              height = 1080;
            };
          };
          userRegistry.profile.features = {
            sops.module = {
              ageKeyFile = "/mock/identity";
              defaultSopsFormat = "yaml";
              defaultSopsFile = ./test.nix;
            };
            agent.module = { config, lib, ... }: {
              pi.providers = lib.mkIf (config.features.sops.enable or false) {
                deepseek = {
                  enable = true;
                  apiKeyFile = config.sops.secrets.key.path;
                };
              };
            };
          };
        };
        nixosConfigurations.one = {
          features.greeter.enable = true;
          users."1000".features = {
            agent.enable = true;
            niri.enable = true;
            sops.enable = true;
          };
          users."1001".features.agent.enable = true;
        };
      }
    ]).nixosConfigurations.one;

  missingGreeterMonitor =
    (evaluate [
      (modules + "/features/greeter/default.nix")
      { nixosConfigurations.one.features.greeter.enable = true; }
    ]).nixosConfigurations.one.features.greeter.module;

  missingGreeterMonitorValue =
    (lib.evalModules {
      modules = [
        {
          options.features.greeter.monitor = mkOption {
            type = types.monitor;
            readOnly = true;
          };
        }
        missingGreeterMonitor
      ];
    }).config.features.greeter.monitor.name;

  connectedOS =
    (lib.evalModules {
      modules = [
        {
          options.features = {
            greeter.monitor = mkOption {
              type = types.monitor;
              readOnly = true;
            };
          };
        }
        connected.features.greeter.module
      ];
    }).config.features;

  connectedHM =
    (lib.evalModules {
      modules = [
        {
          options.features = {
            niri.monitors = mkOption {
              type = types.monitors;
              readOnly = true;
            };
            sops = {
              enable = lib.mkEnableOption "SOPS fixture";
              ageKeyFile = mkOption {
                type = lib.types.nonEmptyStr;
                readOnly = true;
              };
              defaultSopsFormat = mkOption {
                type = lib.types.nullOr str;
                readOnly = true;
              };
              defaultSopsFile = mkOption {
                type = lib.types.nullOr lib.types.path;
                readOnly = true;
              };
              secretsInput = mkOption {
                type = types.sopsSecretsInput;
                readOnly = true;
              };
            };
            agent.pi.providers = mkOption { type = attrsOf lib.types.anything; };
          };
          options.sops.secrets.key.path = mkOption { type = str; };
          config = {
            features.sops.enable = true;
            sops.secrets.key.path = "/run/secrets/key";
          };
        }
        connected.users."1000".features.niri.module
        connected.users."1000".features.sops.module
        connected.users."1000".features.agent.module
      ];
    }).config.features;

  agentWithoutSops =
    (lib.evalModules {
      modules = [
        {
          options.features.agent.pi.providers = mkOption {
            type = attrsOf lib.types.anything;
            default = { };
          };
        }
        connected.users."1001".features.agent.module
      ];
    }).config.features.agent.pi.providers;

  crossReferences = construct (evaluate [
    ({ config, ... }: {
      nixosConfigurations.two = {
        host = config.nixosConfigurations.one.host;
        users."1000" = {
          username = config.nixosConfigurations.one.users."1000".username;
          profile = config.nixosConfigurations.one.users."1000".profile;
        };
      };
    })
  ]);

  expectedMarkers =
    actual: expected: lib.sort builtins.lessThan actual == lib.sort builtins.lessThan expected;
in
assert expectedMarkers os.markers [
  "base"
  "first"
  "2"
  "0"
  "os-implementation"
  "os-consumer"
  "merged"
  "workload"
];
assert os.features.alpha.enable && os.workloads.service.enable;
assert os.users.users."1000".uid == 1000;
assert os.users.users."1000".name == "first";
assert os.users.users."1001".home == "/home/second";
assert
  builtins.attrNames os.accountMetadata == [
    "1000"
    "1001"
  ];
assert os.accountMetadata."1000".username == "first";
assert os.accountMetadata."1000".profile.name == "profile";
assert !(os.accountMetadata."1000" ? features);
assert !(os.accountMetadata."1000".profile ? module);
assert !(os.accountMetadata."1000".profile ? features);
assert os.accountMetadata."1000".profile.identity.keys.ssh == null;
assert (evaluate [ ]).nixosBuilderArgs.hostRegistry.first.identity.keys.age == null;
assert identity.userAgeSecretName 1000 == identity.userAgeSecretName "1000";
assert
  os.age.secrets.${identity.userAgeSecretName "1000"} == {
    rekeyFile = ./test.nix;
    owner = "first";
    group = "root";
    mode = "0400";
  };
assert os.age.secrets.${identity.userAgeSecretName "1001"}.owner == "second";
assert !(builtins.hasAttr (identity.userAgeSecretName "1001") withoutIdentity.age.secrets);
assert (hm "1000").home.uid == 1000;
assert (hm "1000").home.username == "first";
assert (hm "1000").features.alpha.enable;
assert (hm "1000").features.alpha.profileUid == 1000;
assert
  (hm "1000").features.alpha.inputs == [
    "argument"
    "native-argument"
    "consumer"
  ];
assert reusedProfile.features.alpha.profileUid == 1001;
assert !(builtins.tryEval (lib.isFunction duplicateProfileModule)).success;
assert fails [ { nixosBuilderArgs.userRegistry.profile.features.unknown.module = { }; } ];
assert expectedMarkers (hm "1000").markers [
  "profile"
  "shared"
  "hm-implementation"
  "hm-consumer"
];
assert !(hm "1001").features.alpha.enable;
assert expectedMarkers (hm "1001").markers [
  "profile"
  "shared"
];
assert expectedMarkers disabled.markers [
  "base"
  "first"
  "2"
  "0"
];
assert !disabled.features.alpha.enable && !disabled.workloads.service.enable;
assert fails [ { test.secondNumber = 1; } ];
assert failsHostOption "monitors" [
  { nixosBuilderArgs.hostRegistry.second.monitors.missingMode.role = "default"; }
];
assert failsHostOption "users" [ { nixosBuilderArgs.hostRegistry.second.users."01002" = 1002; } ];
assert failsHostOption "wireguard" [
  {
    test.secondWireguard = {
      publicKey = "test-key";
      privateKey = "encrypted-test-key";
      endpoint = {
        address = "example.invalid";
        port = 51820;
      };
    };
  }
];
assert crossHostMonitors.external.name == "external";
assert !(builtins.tryEval missingGreeterMonitorValue).success;
assert fails [ { nixosConfigurations.one.users."1001".username = lib.mkForce "first"; } ];
assert fails [ { nixosConfigurations.one.users."1001".homeDirectory = "relative"; } ];
assert fails [
  {
    nixosConfigurations.one.users."01000" = {
      username = "noncanonical";
      profile = (evaluate [ ]).nixosBuilderArgs.userRegistry.profile;
    };
  }
];
assert fails [
  {
    nixosConfigurations.one.users."1002" = {
      username = "unregistered";
      profile = (evaluate [ ]).nixosBuilderArgs.userRegistry.profile;
    };
  }
];
# Invalid declarations in another system cannot be hidden by only building the first system.
assert fails [
  ({ config, ... }: {
    nixosConfigurations.two = {
      host = config.nixosBuilderArgs.hostRegistry.first;
      users."1000" = {
        username = "invalid";
        homeDirectory = "relative";
        profile = config.nixosBuilderArgs.userRegistry.profile;
      };
    };
  })
];
assert connectedOS.greeter.monitor == connectedHM.niri.monitors."eDP-1";
assert connectedOS.greeter.monitor.name == "eDP-1";
assert connectedHM.niri.monitors."eDP-1".mode.width == 1920;
assert connectedHM.sops.ageKeyFile == "/mock/identity";
assert connectedHM.sops.defaultSopsFormat == "yaml";
assert connectedHM.sops.defaultSopsFile == ./test.nix;
assert connectedHM.agent.pi.providers.deepseek.enable;
assert connectedHM.agent.pi.providers.deepseek.apiKeyFile == "/run/secrets/key";
assert agentWithoutSops == { };
assert
  builtins.attrNames crossReferences == [
    "one"
    "two"
  ];
runCommand "nixos-configurations" { } "touch $out"
