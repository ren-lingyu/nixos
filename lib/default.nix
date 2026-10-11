{ lib }: rec {

  types = rec {

    existModule = import ./types.exist-module.nix { inherit lib; };

    monitor = import ./types.monitor.nix { inherit lib; };

    monitors = lib.types.attrsOf monitor;

  };

  assertions = {

    existModule = import ./assertions.exist-module.nix;

  };

  moduleFunctions = rec {

    configuration = import ./moduleFunctions.configuration.nix {
      inherit lib;
      moduleFunctions = default;
    };

    default = import ./moduleFunctions.default.nix { inherit lib; };

    hosts = {

      default = import ./moduleFunctions.hosts.default.nix { inherit lib; };

    };

    features = {

      sops = import ./moduleFunctions.features.sops.nix;

    };

  };

  packageFunctions = import ./packageFunctions.nix { inherit lib; };

  flake-parts = {
    types = {
      inherit
        (import ./flake-parts.types.nix {
          inherit lib;
          llib = { inherit types moduleFunctions; };
          inherit (moduleFunctions.default) mkOptionTree mkOptionModules mkOptionName;
        })
        nixosBuilder
        moduleRegistry
        nixosConfigurations
        ;
    };
  };

}
