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

    features = {

      default = import ./moduleFunctions.features.default.nix { inherit lib; };

      secret = import ./moduleFunctions.features.secret.nix;

    };

  };

}
