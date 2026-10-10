{
  lib,
  mkOptionTree,
  mkOptionModules,
  mkOptionName,
}:
{
  nixosBuilder = lib.types.submodule {
    options = {
      nixosSystem = lib.mkOption {
        type = lib.types.raw;
        description = "Function used to construct NixOS configurations.";
      };
      homeManager = lib.mkOption {
        type = lib.types.deferredModule;
        description = "Home Manager integration module for NixOS.";
      };
      specialArgs = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = { };
        description = "Additional module arguments shared by NixOS and Home Manager.";
      };
    };
  };

  moduleIntegrations =
    { root, modulesDir }:
    lib.types.submodule {
      options = mkOptionTree {
        inherit root modulesDir;
        pathMapper = lib.drop 1;
        optionMaker =
          descriptor:
          lib.mkOption {
            type = lib.types.submodule {
              options = {
                nixosModules = lib.mkOption {
                  type = lib.types.listOf lib.types.deferredModule;
                  default = [ ];
                  description = "Additional NixOS modules required by this module.";
                };

                nixpkgsOverlays = lib.mkOption {
                  type = lib.types.listOf (
                    lib.mkOptionType {
                      name = "nixpkgs.overlay";
                      description = "Nixpkgs overlay";
                      check = lib.isFunction;
                      merge = lib.mergeOneOption;
                    }
                  );
                  default = [ ];
                  description = "Additional Nixpkgs overlays required by this module.";
                };

                homeModules = lib.mkOption {
                  type = lib.types.listOf lib.types.deferredModule;
                  default = [ ];
                  description = "Additional Home Manager modules for users selected by this module.";
                };
              };
            };
            default = { };
            description = "External integrations for ${mkOptionName descriptor.path}.";
          };
      };
    };

  nixosConfigurations =
    {
      root,
      modulesDir,
      scope ? { },
    }:
    lib.types.attrsOf (
      lib.types.submodule (
        {
          name,
          config,
          options,
          ...
        }:
        {
          options = {
            system = lib.mkOption { type = lib.types.nonEmptyStr; };

            modules = mkOptionTree {
              inherit root modulesDir;
              pathMapper = lib.drop 1;
              optionMaker =
                descriptor:
                lib.mkOption {
                  type = lib.types.submoduleWith {
                    modules = mkOptionModules {
                      inherit root;
                      scope = scope // {
                        inherit lib config options;
                      };
                    } descriptor.path;
                  };
                  default = { };
                  description = "Options for ${
                    mkOptionName (
                      builtins.concatLists [
                        [
                          "nixosConfigurations"
                          name
                        ]
                        descriptor.path
                      ]
                    )
                  }.";
                };
            };

            specialArgs = lib.mkOption {
              type = lib.types.attrsOf lib.types.raw;
              default = { };
            };
          };
        }
      )
    );
}
