{
  options,
  config,
  pkgs,
  lib,
  llib,
  ...
}:
let

  cfg = config.modules.hosts;

  mif = llib.hosts;

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

in
{
  options = {
    networking.wireguard.topology = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            nodes = lib.mkOption { type = lib.types.attrsOf lib.types.str; };
          };
        }
      );
      internal = true;
      readOnly = true;
    };
  };

  config = {
    age.secrets = lib.mkIf (enabledHost_.wireguard != null) {
      wireguard = {
        rekeyFile = enabledHost_.wireguard.privateKey;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    networking =
      let
        wireguardNetworks_ = (
          mif.mkWireGuardNetworks {
            registry = cfg;
            privateKeyFile = config.age.secrets.wireguard.path;
            wgIpRule = (x_: y_: "10.100.${builtins.toString x_}.${builtins.toString y_}");
            wgNameRule = (x_: "wg${builtins.toString x_}");
          }
        );
      in
      (lib.mkMerge [
        wireguardNetworks_.config
        { wireguard.topology = wireguardNetworks_.topology; }
      ]);
  };
}
