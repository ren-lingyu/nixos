{
  config,
  host,
  hostTopology,
  pkgs,
  lib,
  llib,
  ...
}:
let

  cfg = config.workloads.caddy;

  interfaceNames_ = llib.hosts.getManagedWireGuardInterfaces {
    topology = hostTopology;
    hostName = host.name;
  };

  principal_ = "meta skuid ${builtins.toString config.ids.uids.caddy}";

  upstream_ = ''oifname "${cfg.networkInterface}" ip daddr ${cfg.ip} tcp dport ${builtins.toString cfg.port}'';

in
{
  options.workloads.caddy = {
    enable = lib.mkEnableOption "caddy workload";
    ip = lib.mkOption { type = lib.types.nonEmptyStr; };
    port = lib.mkOption { type = lib.types.port; };
    networkInterface = lib.mkOption { type = lib.types.nonEmptyStr; };
  };

  config = lib.mkIf cfg.enable {
    base.wireguard.firewall.extraOutputAllowRules = "${principal_} ${upstream_} accept";

    networking.nftables.tables.workload-caddy-egress = lib.mkIf (interfaceNames_ != [ ]) {
      family = "inet";
      content = ''
        chain output {
          type filter hook output priority filter; policy accept;

          ${principal_} oifname { ${
            lib.concatMapStringsSep ", " (name: ''"${name}"'') interfaceNames_
          } } jump restricted-output
        }

        chain restricted-output {
          ct direction reply ct state established accept
          ct direction reply ct state related meta l4proto { icmp, ipv6-icmp } accept

          ${upstream_} accept

          reject
        }
      '';
    };

    containers.caddy = rec {
      privateNetwork = false;
      autoStart = false;
      restartIfChanged = false;
      bindMounts = {
        caddyConfigEnv = {
          hostPath = "/var/lib/caddy/.config/caddy/config.env";
          mountPoint = "/run/caddy/config.env";
          isReadOnly = true;
        };
      };
      config = {
        services.caddy = {
          enable = true;
          package = pkgs.caddy;
          environmentFile = bindMounts.caddyConfigEnv.mountPoint;
          virtualHosts = {
            "{$DOMAIN_${builtins.toString cfg.port}}" = {
              extraConfig = "reverse_proxy ${cfg.ip}:${builtins.toString cfg.port}";
            };
          };
        };
      };
    };
  };
}
