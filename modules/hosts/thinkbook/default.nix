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
      users = {
        "1000" = 1000;
      };
      monitors = {
        "eDP-1" = {
          name = "eDP-1";
          role = "default";
          mode = {
            width = 3072;
            height = 1920;
            refresh = 60.0;
          };
          scale = 1.6;
        };
        "HDMI-A-1" = {
          name = "HDMI-A-1";
          role = null;
          mode = null;
          scale = 1.0;
        };
      };
      existModule = {
        os = true;
        hm = false;
      };
    };

    assertions = [
      {
        assertion = !cfg.flatpak.enable || cfg.enable;
        message = "`modules.hosts.${hostName_}.flatpak.enable = true` requires `modules.hosts.${hostName_}.enable = true` to exist.";
      }
    ];

  };

}
