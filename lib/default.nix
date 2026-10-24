{ lib }: rec {
  types = rec {
    monitor = import ./types.monitor.nix { inherit lib; };

    monitors = lib.types.attrsOf monitor;
  };

  modules = import ./modules.nix { inherit lib; };

  hosts = import ./hosts.nix { inherit lib; };

  features.sops = import ./features.sops.nix;

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
