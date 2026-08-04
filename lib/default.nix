{ lib } : {

  types = rec {

    monitor = import ./types.monitor.nix { inherit lib; };

    monitors = lib.types.attrsOf monitor;

  };

  moduleFunctions = {

    features = {

      secret = import ./modules.feature.secret.nix;

    };

  };

}
