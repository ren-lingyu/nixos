{ config, pkgs, lib, ... } : let

  cfg = config.modules.hosts.thinkbook;

  hostName_ = "thinkbook";

in {

  imports = [
    ./os
  ];

  config = {

    modules.hosts.thinkbook = {
      enable = true;
      existModule = {
        os = true;
        hm = false;
      };
    };

    assertions = [
      {
        assertion = !cfg.flatpak.enable || cfg.enable;
        message = "`modules.hosts.${hostName_}.flatpak.enable = true` requires `modules.hosts.${hostName_}.enable = true`.";
      }
    ];

  };

}
