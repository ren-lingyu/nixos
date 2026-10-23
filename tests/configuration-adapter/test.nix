{
  lib,
  runCommand,
  rootPath,
  flakeParts,
  modules,
  types,
}:
let
  declarationLib_ = { inherit types; };

  options_ = {
    plain = lib.mkOption { type = lib.types.bool; };
    package = lib.mkOption { type = lib.types.functionTo lib.types.str; };
    nested = lib.mkOption {
      type = lib.types.submodule {
        options.value = lib.mkOption { type = lib.types.functionTo lib.types.str; };
      };
    };
    untouched = lib.mkOption { type = lib.types.raw; };
  };

  config_ = {
    plain = true;
    package = { value, ... }: value;
    nested.value = { value, ... }: "nested-${value}";
    untouched = {
      function = _: "Do not call this function";
    };
  };

  result_ = flakeParts.adaptOptions options_ config_ { value = "resolved"; };

  root_ = rootPath;
  registryType_ = flakeParts.types.moduleRegistry {
    llib = declarationLib_;
    root = root_;
    modulesDir = root_ + "/modules";
  };
  evalRegistry_ =
    definitions:
    (lib.evalModules {
      modules = [
        {
          options.registry = lib.mkOption {
            type = registryType_;
            default = { };
          };
        }
      ]
      ++ definitions;
    }).config.registry;
  registry_ = evalRegistry_ [ ];
  configuration_ =
    (lib.evalModules {
      modules = [
        {
          options.systems = lib.mkOption {
            type = flakeParts.types.nixosConfigurations {
              root = root_;
              modulesDir = root_ + "/modules";
              scope = {
                llib = declarationLib_;
                moduleRegistry = registry_;
              };
            };
          };
          config.systems.test = {
            system = "x86_64-linux";
            modules.users.lingyu = {
              enable = true;
              uid = 1000;
            };
          };
        }
      ];
    }).config.systems.test;
  # Inspect the real builder's generated bridge without evaluating OS services.
  bridge_ = flakeParts.mkNixosSystem {
    rootPath = root_;
    registry = registry_;
    systemConfiguration = configuration_;
    builder = {
      homeManager = { };
      specialArgs = { };
      nixosSystem =
        args:
        (builtins.elemAt args.modules 1) {
          inherit lib;
          pkgs = { };
          config = { };
        };
    };
  };
  evaluationFails_ = value: !(builtins.tryEval (builtins.deepSeq value true)).success;
  availabilityTests_ = [
    (
      registry_.features.proxy.metadata.existModule == {
        os = true;
        hm = false;
      }
    )
    (
      registry_.features.editor.metadata.existModule == {
        os = false;
        hm = true;
      }
    )
    (
      registry_.features.niri.metadata.existModule == {
        os = true;
        hm = true;
      }
    )
    (!(builtins.pathExists (root_ + "/modules/features/editor/_metadata.fp.nix")))
    (builtins.all (
      descriptor:
      let
        path = lib.drop 1 descriptor.path;
        availability = (lib.getAttrFromPath path registry_).metadata.existModule;
      in
      builtins.isBool availability.os
      && builtins.isBool availability.hm
      && (lib.getAttrFromPath path bridge_.config.modules).existModule == availability
    ) (modules.discoverModules root_ (root_ + "/modules")))
    (evaluationFails_
      (evalRegistry_ [ { registry.features.editor.metadata.existModule.os = true; } ])
      .features.editor.metadata.existModule
    )
    (evaluationFails_
      (evalRegistry_ [ { registry.features.editor.metadata.existModule.hm = true; } ])
      .features.editor.metadata.existModule
    )
    (configuration_.modules.features.editor.allowUidList == [ 1000 ])
    (configuration_.modules.features.niri.allowUidList == [ 1000 ])
    (configuration_.modules.features.proxy.allowUidList == [ ])
    (!configuration_.modules.features.editor.enable)
    (
      !(builtins.elem (
        root_ + "/modules/features/editor/hm/default.nix"
      ) bridge_.config.home-manager.users."1000".imports)
    )
  ];

in
assert builtins.all (test: test) availabilityTests_;
assert result_.plain;
assert result_.package == "resolved";
assert result_.nested.value == "nested-resolved";
assert builtins.isFunction result_.untouched.function;
runCommand "nixos-configuration-adapter" { } ''
  touch $out
''
