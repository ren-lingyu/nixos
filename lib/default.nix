{ lib }: rec {

  types = rec {

    existModule = import ./types.exist-module.nix { inherit lib; };

    monitor = import ./types.monitor.nix { inherit lib; };

    monitors = lib.types.attrsOf monitor;

  };

  modules = (import ./modules.nix { inherit lib; }) // {
    assertions.existModule = import ./modules.assertions.exist-module.nix;
  };

  hosts = import ./hosts.nix { inherit lib; };

  features.sops = import ./features.sops.nix;

  packages = import ./packages.nix { inherit lib; };

  flakeParts =
    (import ./flakeParts.configurations.nix {
      inherit lib;
      moduleTools = modules;
    })
    // {
      types = {
        inherit
          (import ./flakeParts.types.nix {
            inherit lib;
            llib = { inherit types modules; };
            inherit (modules) mkOptionTree mkOptionModules mkOptionName;
          })
          nixosBuilder
          moduleRegistry
          nixosConfigurations
          ;
      };
    };

}
