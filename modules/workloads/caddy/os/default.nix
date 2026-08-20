{ config, pkgs, lib, ... } : let

  cfg = config.modules.workloads.caddy;

in {

  config = lib.mkIf cfg.enable {

    networking = {
      nftables = {
        tables = {
          workload-caddy-egress = {
            family = "inet";
            content = "chain output {${
              (builtins.concatStringsSep
                "\n"
                [
                  "type filter hook output priority filter; policy accept;"
                  "oifname \"${cfg.networkInterface}\" ip daddr ${cfg.ip} tcp dport ${builtins.toString cfg.port} meta skuid ${builtins.toString config.ids.uids.caddy} accept;"
                  "oifname \"${cfg.networkInterface}\" reject;"
                ]
              )
            }}";
          };
        };
      };
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
        environment.enableAllTerminfo = true;
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
