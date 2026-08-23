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
        assertion = (builtins.any
          (x_ : x_)
          [
            (!cfg.flatpak.enable)
            cfg.enable
          ]
        );
        message = "`modules.hosts.${hostName_}.flatpak.enable = true` requires `modules.hosts.${hostName_}.enable = true`.";
      }
      {
        assertion = (builtins.any
          (x_ : x_)
          [
            (!cfg.windows.mount.enable)
            cfg.enable
          ]
        );
        message = "`modules.hosts.${hostName_}.windows.mount.enable = true` requires `modules.hosts.${hostName_}.enable = true`.";
      }
      {
        assertion = (builtins.any
          (x_ : x_)
          [
            (!cfg.windows.virtualisation.enable)
            cfg.enable
          ]
        );
        message = "`modules.hosts.${hostName_}.windows.virtualisation.enable = true` requires `modules.hosts.${hostName_}.enable = true`.";
      }
      {
        assertion = (lib.count
          (x_ : x_)
          [
            cfg.windows.mount.enable
            cfg.windows.virtualisation.enable
          ]
        ) <= 1;
        message = "At most one of `modules.hosts.${hostName_}.windows.mount.enable` and `modules.hosts.${hostName_}.windows.virtualisation.enable` can be true.";
      }
    ];

  };

}
