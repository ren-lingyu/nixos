{
  lib,
  runCommand,
  flakeParts,
  modules,
  moduleLib,
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

  registryType_ = flakeParts.types.moduleRegistry {
    llib = declarationLib_;
    inherit modules;
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
  evalConfiguration_ =
    registry: overrides:
    (lib.evalModules {
      modules = [
        {
          options.systems = lib.mkOption {
            type = flakeParts.types.nixosConfigurations {
              inherit modules;
              llib = declarationLib_;
              inherit registry;
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
      ]
      ++ overrides;
    }).config.systems.test;
  configuration_ = evalConfiguration_ registry_ [ ];
  # Inspect the real builder's generated bridge without evaluating OS services.
  bridge_ = flakeParts.mkNixosSystem {
    inherit modules;
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
  allocationRegistry_ = evalRegistry_ [
    {
      registry.features.editor.homeModules = [
        { options.sampleUpstream = lib.mkEnableOption "upstream fixture"; }
        { options.sampleImplementation = lib.mkEnableOption "implementation fixture"; }
        {
          sampleUpstream = true;
          sampleImplementation = true;
        }
      ];
    }
  ];
  allocationConfiguration_ = evalConfiguration_ allocationRegistry_ [
    {
      config.systems.test.modules = {
        users.lingyu-minimal = {
          enable = true;
          uid = 1001;
        };
        features.editor = {
          enable = true;
          allowUidList = [ 1001 ];
        };
      };
    }
  ];
  allocated_ =
    flakeParts.homeUserModules
      (flakeParts.enabledModules (moduleLib.discoverModules modules) allocationConfiguration_)
      allocationConfiguration_
      allocationRegistry_;
  allocationOptions_ =
    (lib.evalModules {
      modules = builtins.filter (module: !builtins.isPath module) allocated_."1001".imports;
    }).config;
  availabilityTests_ = [
    (
      registry_.features.proxy.metadata.existModule == {
        os = true;
        hm = false;
      }
    )
    (
      registry_.features.editor.metadata.existModule == {
        os = true;
        hm = true;
      }
    )
    (
      registry_.features.niri.metadata.existModule == {
        os = true;
        hm = true;
      }
    )
    (!(builtins.pathExists (modules + "/features/editor/_metadata.fp.nix")))
    (builtins.all (
      descriptor:
      let
        path = lib.drop 1 descriptor.path;
        availability = (lib.getAttrFromPath path registry_).metadata.existModule;
      in
      builtins.isBool availability.os
      && builtins.isBool availability.hm
      && (lib.getAttrFromPath path bridge_.config.modules).existModule == availability
    ) (moduleLib.discoverModules modules))
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
    (builtins.length allocated_."1000".imports == 1)
    (builtins.length allocated_."1001".imports == 5)
    allocationOptions_.sampleUpstream
    allocationOptions_.sampleImplementation
    (
      !(builtins.elem (
        modules + "/features/editor/hm/default.nix"
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
