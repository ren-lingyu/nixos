{
  lib,
  deferredModuleFragment,
  mapModule,
}:
let
  inherit (lib) mkOption types;

  moduleOption = mkOption {
    type = types.deferredModule;
    default = { };
    description = "Native module to be imported in the selected evaluation scope.";
  };

  registryEntry = { name, ... }: {
    options = {
      name = mkOption {
        type = types.nonEmptyStr;
        readOnly = true;
        default = name;
      };
      module = moduleOption;
    };
  };

  mkFeatureModule = name: module: mapModule (value: { config.features.${name} = value; }) module;

  selection =
    registry:
    mkOption {
      type = types.submodule {
        options = lib.mapAttrs (
          name: _:
          mkOption {
            type = types.submodule {
              options = {
                enable = lib.mkEnableOption name;
                module = moduleOption;
              };
            };
            default = { };
          }
        ) registry;
      };
      default = { };
    };

  registryReference =
    registry:
    mkOption {
      type = types.unique { message = "Select exactly one registry entry."; } types.raw;
      apply = entry: registry.${entry.name};
      description = "A selected entry from the corresponding FP registry.";
    };

  selectedModules =
    namespace: registry: selections:
    lib.concatLists (
      lib.mapAttrsToList (
        name: selected:
        lib.optionals selected.enable [
          registry.${name}
          selected.module
          (lib.setAttrByPath [ namespace name "enable" ] true)
        ]
      ) selections
    );

  uidOf =
    uid:
    assert lib.assertMsg (
      builtins.match "[1-9][0-9]*" uid != null
    ) "Account key `${uid}` must be a canonical decimal UID.";
    builtins.fromJSON uid;

  validateSelections =
    selections: builtins.all (selected: builtins.isBool selected.enable) (lib.attrValues selections);

  validateAccounts =
    name: system:
    let
      usernames = lib.mapAttrsToList (_: account: account.username) system.users;
    in
    assert lib.assertMsg (
      builtins.length usernames == builtins.length (lib.unique usernames)
    ) "System `${name}` must have unique account login names.";
    builtins.all (valid: valid) (
      lib.mapAttrsToList (
        uid: account:
        assert lib.assertMsg (
          uidOf uid >= 1000
        ) "System `${name}` account UID `${uid}` must be at least 1000.";
        assert lib.assertMsg (
          (system.host.users.${uid} or null) == uidOf uid
        ) "System `${name}` account UID `${uid}` must be registered in its Host.";
        assert lib.assertMsg (lib.hasPrefix "/" account.homeDirectory)
          "System `${name}` account `${uid}` must have an absolute home directory.";
        builtins.seq account.profile.name (validateSelections account.features)
      ) system.users
    );

  mkAccountModule = uid: account: homeRegistry: {
    users.users.${uid} = {
      isNormalUser = lib.mkForce true;
      uid = lib.mkForce (uidOf uid);
      name = lib.mkForce account.username;
      createHome = lib.mkForce true;
      home = lib.mkForce account.homeDirectory;
    };

    home-manager.users.${uid} = {
      imports = [ account.profile.module ] ++ selectedModules "features" homeRegistry account.features;
      home = {
        uid = lib.mkForce (uidOf uid);
        username = lib.mkForce account.username;
        homeDirectory = lib.mkForce account.homeDirectory;
      };
    };
  };

  mkNixosSystem =
    builderArgs: system:
    builderArgs.nixosSystem {
      # Platform is declared by the Host module via `nixpkgs.hostPlatform`.
      system = null;
      specialArgs = builderArgs.specialArgs // {
        host = builtins.removeAttrs system.host [ "module" ];
        hostRegistry = lib.mapAttrs (
          _: host: builtins.removeAttrs host [ "module" ]
        ) builderArgs.hostRegistry;
        hostTopology = builderArgs.hostTopology;
      };
      modules = [
        builderArgs.homeManager
        builderArgs.baseModule
        system.host.module
        { home-manager.extraSpecialArgs = builderArgs.specialArgs; }
      ]
      ++ selectedModules "features" builderArgs.featureRegistry.os system.features
      ++ selectedModules "workloads" builderArgs.workloadRegistry system.workloads
      ++ lib.mapAttrsToList (
        uid: account: mkAccountModule uid account builderArgs.featureRegistry.hm
      ) system.users;
    };
in
{
  mkOptions = fpConfig: {
    nixosBuilderArgs = {
      nixosSystem = mkOption { type = types.raw; };
      homeManager = mkOption { type = types.deferredModule; };
      baseModule = moduleOption;
      specialArgs = mkOption {
        type = types.attrsOf types.raw;
        default = { };
      };
      hostRegistry = mkOption {
        type = types.attrsOf (types.submodule registryEntry);
        default = { };
      };
      userRegistry = mkOption {
        type = types.attrsOf (
          types.submodule [
            registryEntry
            {
              options.features = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options.module = mkOption {
                      type = deferredModuleFragment;
                      readOnly = true;
                      description = "User-supplied native configuration definitions under this Feature's namespace.";
                    };
                  }
                );
                default = { };
              };
            }
          ]
        );
        default = { };
      };
      hostTopology = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              name = mkOption { type = types.str; };
              subnet = mkOption { type = types.str; };
              nodes = mkOption { type = types.attrsOf types.str; };
            };
          }
        );
        readOnly = true;
      };
      featureRegistry = lib.genAttrs [ "os" "hm" ] (
        _:
        mkOption {
          type = types.attrsOf types.deferredModule;
          default = { };
        }
      );
      workloadRegistry = mkOption {
        type = types.attrsOf types.deferredModule;
        default = { };
      };
    };

    nixosConfigurations = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            host = registryReference fpConfig.nixosBuilderArgs.hostRegistry;
            features = selection fpConfig.nixosBuilderArgs.featureRegistry.os;
            workloads = selection fpConfig.nixosBuilderArgs.workloadRegistry;
            users = mkOption {
              type = types.attrsOf (
                types.submodule (
                  { config, ... }: {
                    options = {
                      username = mkOption { type = types.nonEmptyStr; };
                      homeDirectory = mkOption {
                        type = types.str;
                        default = "/home/${config.username}";
                      };
                      profile = registryReference fpConfig.nixosBuilderArgs.userRegistry;
                      features = selection fpConfig.nixosBuilderArgs.featureRegistry.hm;
                    };
                    config.features = lib.mapAttrs (name: entry: {
                      module = mkFeatureModule name entry.module;
                    }) config.profile.features;
                  }
                )
              );
              default = { };
            };
          };
        }
      );
      default = { };
    };
  };

  mkNixosConfigurations =
    { builderArgs, configurations }:
    assert builtins.seq builderArgs.hostRegistry true;
    assert builtins.all (valid: valid) (
      lib.mapAttrsToList (
        name: system:
        builtins.seq system.host.name (
          validateAccounts name system
          && validateSelections system.features
          && validateSelections system.workloads
        )
      ) configurations
    );
    lib.mapAttrs (_: system: mkNixosSystem builderArgs system) configurations;
}
