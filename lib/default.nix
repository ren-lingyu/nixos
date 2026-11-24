{ lib }: rec {
  modules = import ./modules.nix { inherit lib; };

  hosts = import ./hosts.nix { inherit lib; };

  flakeParts = lib.mergeAttrsList [
    (import ./flakeParts.configurations.nix {
      inherit lib;
      inherit (modules) discoverModules mkOptionTree;
    })
    (import ./flakeParts.validators.nix {
      inherit lib;
      inherit (modules) discoverValidatorFiles;
    })
    {
      types = {
        inherit
          (import ./flakeParts.types.nix {
            inherit lib;
            inherit (modules) mkOptionTree mkOptionModules mkOptionName;
          })
          nixosBuilder
          moduleRegistry
          nixosConfigurations
          ;
      };
    }
  ];
}
