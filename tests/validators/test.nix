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
  fixture = name: ./. + "/fixtures/${name}";
  applications =
    name:
    flakeParts.mkValidatorApplications {
      llib = {
        marker = 42;
        unused = throw "unrelated validator context forced";
      };
      modules = fixture name + "/modules";
    };
  fails = value: !(builtins.tryEval (builtins.seq value true)).success;
  check = name: value: if value then true else throw "FP validator test failed: ${name}";
  eval =
    {
      validators ? "hierarchy",
      actual ? false,
      registry ? { },
      systems ? { },
    }:
    let
      moduleDirectory = if actual then modules else fixture "hierarchy" + "/modules";
      apply = applications validators;
    in
    (lib.evalModules {
      modules = [
        ({ config, ... }: {
          options.moduleRegistry = lib.mkOption {
            type = flakeParts.types.moduleRegistry {
              llib = declarationLib_;
              modules = moduleDirectory;
            };
            readOnly = true;
            apply = apply.moduleRegistry;
          };
          options.nixosConfigurations = lib.mkOption {
            type = flakeParts.types.nixosConfigurations {
              modules = moduleDirectory;
              llib = declarationLib_;
              registry = config.moduleRegistry;
            };
            readOnly = true;
            apply = apply.nixosConfigurations config.moduleRegistry;
          };
          config.moduleRegistry = registry;
          config.nixosConfigurations =
            if actual then
              {
                valid = {
                  system = "x86_64-linux";
                  specialArgs.unrelated = throw "unrelated specialArgs forced";
                  modules = {
                    users.lingyu = {
                      enable = true;
                      uid = config.moduleRegistry.hosts.thinkbook.metadata.users."1000";
                      username = "fixture";
                    };
                    features.niri.enable = true;
                    workloads.wbo.port = _: throw "functionTo value called prematurely";
                  };
                };
              }
            else
              systems;
        })
      ];
    }).config;
  valid = {
    system = "x86_64-linux";
  };
  evaluated = eval {
    systems = {
      inherit valid;
      invalid = valid;
      assertion = valid;
    };
  };
  dependencies = eval {
    validators = "dependencies";
    actual = true;
    registry.features.editor = {
      nixosModules = [
        (_: throw "external OS module evaluated")
        (throw "external OS module value forced")
      ];
      homeModules = [
        (_: throw "external HM module evaluated")
        (throw "external HM module value forced")
      ];
      nixpkgsOverlays = [
        (_: _: throw "overlay called")
        (throw "overlay value forced")
      ];
    };
  };
  discovered = moduleLib.discoverValidatorFiles { modules = fixture "hierarchy" + "/modules"; };
  relocatedModules = fixture "directory-interface";
  relocatedPath = [
    "modules"
    "features"
    "alpha"
  ];
  relocatedDeclarations =
    (lib.evalModules {
      modules = moduleLib.mkOptionModules.metadata {
        modules = relocatedModules;
        scope = { inherit lib; };
      } relocatedPath;
    }).config;
  tests = [
    (check "module directory is independent of its physical name and repository root" (
      builtins.map (descriptor: descriptor.path) (moduleLib.discoverModules relocatedModules)
      == [ relocatedPath ]
      && relocatedDeclarations.marker == 42
      &&
        (flakeParts.mkValidatorApplications {
          modules = relocatedModules;
          llib = { };
        }).moduleRegistry
          relocatedDeclarations == {
          marker = 42;
        }
    ))
    (check "ordered, deduplicated hierarchy including missing intermediate file" (
      builtins.map (entry: entry.path) discovered == [
        [ "modules" ]
        [
          "modules"
          "features"
        ]
        [
          "modules"
          "features"
          "alpha"
        ]
        [
          "modules"
          "other"
          "gamma"
        ]
      ]
    ))
    (check "no validators" (
      moduleLib.discoverValidatorFiles { modules = fixture "empty" + "/modules"; } == [ ]
    ))
    (check "identity with no validators" (
      (applications "empty").moduleRegistry { marker = 42; } == { marker = 42; }
    ))
    (check "metadata-only" (
      (applications "metadata-only").moduleRegistry { marker = 42; } == { marker = 42; }
    ))
    (check "configuration-only metadata boundary" (
      (applications "configuration-only").moduleRegistry { } == { }
    ))
    (check "configuration-only identity" (
      ((applications "configuration-only").nixosConfigurations { } {
        valid = {
          marker = 42;
        };
      }).valid.marker == 42
    ))
    (check "optional branches" ((applications "empty-branches").moduleRegistry { } == { }))
    (check "typed registry and system receive branch-only library context lazily" (
      evaluated.moduleRegistry.features.alpha.metadata.number == 1
      && evaluated.nixosConfigurations.valid.system == "x86_64-linux"
    ))
    (check "invalid system is rejected independently" (
      fails evaluated.nixosConfigurations.invalid.system
    ))
    (check "configuration assertion" (fails evaluated.nixosConfigurations.assertion.system))
    (check "all metadata constraints" (
      builtins.all
        (
          number:
          fails
            (eval { registry.features.alpha.metadata.number = number; })
            .moduleRegistry.features.alpha.metadata.number
        )
        [
          0
          2
          3
        ]
    ))
    (check "all configuration constraints" (
      builtins.all
        (
          flag:
          fails
            (eval {
              systems.invalidFlag = valid // {
                specialArgs.${flag} = false;
              };
            }).nixosConfigurations.invalidFlag.system
        )
        [
          "root"
          "category"
          "module"
        ]
    ))
    (check "invalid declarations/results and assertion failure" (
      builtins.all (name: fails ((applications name).moduleRegistry { })) [
        "false"
        "assertion"
        "result"
        "unknown"
        "branch"
        "structure"
        "not-function"
      ]
    ))
    (check "configuration false and non-boolean results" (
      builtins.all
        (name: fails ((applications name).nixosConfigurations { } { inherit valid; }).valid.system)
        [
          "configuration-false"
          "configuration-result"
          "configuration-branch"
        ]
    ))
    (check "unrelated configurations stay lazy" (
      ((applications "lazy").nixosConfigurations { } {
        valid.specialArgs.check = true;
        invalid.specialArgs.check = throw "unrelated system forced";
      }).valid.specialArgs.check
    ))
    (check "real FP defaults and explicit metadata dependency" (
      dependencies.nixosConfigurations.valid.modules.users.lingyu.homeDirectory == "/home/fixture"
    ))
  ];
in
assert builtins.all (test: test) tests;
runCommand "nixos-fp-validators" { } ''
  touch $out
''
