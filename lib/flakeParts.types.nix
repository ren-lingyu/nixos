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

  moduleRegistry =
    { modules, llib }:
    lib.types.submodule {
      options = mkOptionTree {
        inherit modules;
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

                metadata = lib.mkOption {
                  type = lib.types.submoduleWith {
                    modules = builtins.concatLists [
                      [
                        {
                          options.existModule = lib.mkOption {
                            type = lib.types.submodule {
                              options = lib.genAttrs [ "os" "hm" ] (
                                unused_side:
                                lib.mkOption {
                                  type = lib.types.bool;
                                  readOnly = true;
                                }
                              );
                            };
                            readOnly = true;
                            internal = true;
                            description = "Availability derived from module discovery.";
                          };
                          config.existModule = {
                            os = descriptor.os != null;
                            hm = descriptor.hm != null;
                          };
                        }
                        ({ config, options, ... }: {
                          imports = mkOptionModules.metadata {
                            inherit modules;
                            scope = {
                              inherit
                                lib
                                llib
                                config
                                options
                                ;
                            };
                          } descriptor.path;
                        })
                      ]
                      (lib.optionals (builtins.pathExists (descriptor.module + "/_metadata.fp.nix")) [
                        {
                          _file = descriptor.module + "/_metadata.fp.nix";
                          config = import (descriptor.module + "/_metadata.fp.nix");
                        }
                      ])
                    ];
                  };
                  default = { };
                  internal = true;
                  readOnly = true;
                  description = "Metadata for ${mkOptionName descriptor.path}.";
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
      modules,
      llib,
      registry,
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
              inherit modules;
              pathMapper = lib.drop 1;
              optionMaker =
                descriptor:
                lib.mkOption {
                  type = lib.types.submoduleWith {
                    modules = mkOptionModules.configuration {
                      inherit modules;
                      scope = {
                        inherit
                          lib
                          llib
                          config
                          options
                          ;
                        moduleRegistry = registry;
                      };
                      metadata = lib.getAttrFromPath (lib.drop 1 descriptor.path ++ [ "metadata" ]) registry;
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

            moduleOptions = lib.mkOption {
              type = lib.types.raw;
              default = options.modules;
              readOnly = true;
              internal = true;
              description = "Option declarations for this system’s configuration adapter.";
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
