{
  options,
  config,
  host,
  hostRegistry,
  hostTopology,
  pkgs,
  lib,
  llib,
  ...
}:
{
  options = {
    networking.wireguard.topology = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            subnet = lib.mkOption { type = lib.types.str; };
            nodes = lib.mkOption { type = lib.types.attrsOf lib.types.str; };
          };
        }
      );
      internal = true;
      readOnly = true;
    };
  };

  config = {
    assertions = [
      {
        assertion = host.wireguard == null || config.networking.nftables.enable;
        message = "WireGuard routing isolation requires networking.nftables.enable.";
      }
    ];

    boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf (
      host.wireguard != null && host.wireguard.endpoint != null
    ) 1;

    age.secrets = lib.mkIf (host.wireguard != null) {
      wireguard = {
        rekeyFile = host.wireguard.privateKey;
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    networking =
      let
        wireguardNetworks_ = (
          llib.hosts.mkWireGuardNetworks {
            registry = hostRegistry;
            hostName = host.name;
            privateKeyFile = config.age.secrets.wireguard.path;
          }
        );
      in
      (lib.mkMerge [
        wireguardNetworks_.config
        { wireguard.topology = hostTopology; }
      ]);
  };
}
