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
let

  interfaceNames_ = llib.hosts.getManagedWireGuardInterfaces {
    topology = hostTopology;
    hostName = host.name;
  };

in
{
  options = {
    base.wireguard.firewall = {
      restrictOutput = lib.mkOption {
        type = lib.types.bool;
        internal = true;
        readOnly = true;
        description = "Whether to restrict locally initiated traffic on managed WireGuard interfaces.";
      };

      extraOutputAllowRules = lib.mkOption {
        type = lib.types.lines;
        internal = true;
        default = "";
        description = "Additional nftables allow rules for managed WireGuard output.";
      };
    };

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

    networking = lib.mkMerge [
      (llib.hosts.mkWireGuardNetworks {
        registry = hostRegistry;
        hostName = host.name;
        privateKeyFile = config.age.secrets.wireguard.path;
      })
      { wireguard.topology = hostTopology; }
      (lib.mkIf (config.base.wireguard.firewall.restrictOutput && interfaceNames_ != [ ]) {
        nftables.tables.wireguard-egress = {
          family = "inet";
          content = ''
            chain output {
              type filter hook output priority filter; policy accept;

              oifname { ${
                lib.concatMapStringsSep ", " (name: ''"${name}"'') interfaceNames_
              } } jump restricted-output
            }

            chain restricted-output {
              ct direction reply ct state established accept
              ct direction reply ct state related meta l4proto { icmp, ipv6-icmp } accept

              ${config.base.wireguard.firewall.extraOutputAllowRules}

              reject
            }
          '';
        };
      })
    ];
  };
}
