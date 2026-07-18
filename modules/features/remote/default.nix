{ config, lib, pkgs, ... } : let

  cfg = config.modules.features.remote;

in {

  config = {

    modules.features.remote.existModule = {
      os = true;
      hm = true;
    };

    assertions = [
      {
        assertion = !cfg.enable || config.modules.features.secret.enable;
        message = "`modules.features.remote.enable = true` requires `modules.features.secret.enable = true`.";
      }
    ];

  };

}
