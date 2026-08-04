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

      secret = import ./modules.feature.secret.nix;

    };

  };

}
