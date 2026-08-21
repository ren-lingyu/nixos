{ lib } : {

  types = rec {

    existModule = import ./types.exist-module.nix { inherit lib; };

    monitor = import ./types.monitor.nix { inherit lib; };

    monitors = lib.types.attrsOf monitor;

  };

  assertions = {

    existModule = import ./assertions.exist-module.nix;

  };

  moduleFunctions = {

    default = import ./moduleFunctions.default.nix { inherit lib; };

    hosts = {

      default = import ./moduleFunctions.hosts.default.nix { inherit lib; };

    };

    features = {

      default = import ./moduleFunctions.features.default.nix { inherit lib; };

      sops = import ./moduleFunctions.features.sops.nix;

    };

  };

}
