{ config, pkgs, lib, llib, ... } : let

  cfg = config.modules.hosts;

  mif = llib.moduleFunctions.hosts.default;

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

in {

  config = {

    age.secrets = lib.mkIf (enabledHost_.wireguard != null) {
      wireguard = {
        rekeyFile = enabledHost_.wireguard.privateKey;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    networking = mif.mkWireGuardNetworking {
      registry = cfg;
      privateKeyFile = config.age.secrets.wireguard.path;
      wgIpRule = (x_ : y_ : "10.100.${builtins.toString x_}.${builtins.toString y_}");
      wgNameRule = (x_ : "wg${builtins.toString x_}");
    };

  };

}
