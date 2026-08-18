{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.interconnect;

in {

  config = lib.mkIf cfg.enable (lib.mkMerge [

    {

      networking.wireguard.enable = true;

    }

    (lib.mkIf cfg.intranets.ingress.hub.claimed {

      age.secrets = {
        interconnect-wireguard-ingress-hub = {
          rekeyFile = ./ingress.hub.age;
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };

      networking = {

        nftables = {
          tables = {
            interconnect-ingress-hub = {
              family = "inet";
              content = "chain output {${
                (builtins.concatStringsSep
                  "\n"
                  [
                    "type filter hook output priority filter; policy accept;"
                    "oifname \"wg0\" ip daddr ${cfg.intranets.ingress.spoke.intraIpAddress} meta skuid ${builtins.toString cfg.intranets.ingress.hub.principalUid} accept;"
                    "oifname \"wg0\" reject;"
                  ]
                )
              }}";
            };
          };
        };

        firewall = {
          allowedUDPPorts = [
            51820
          ];
          allowedTCPPorts = [
            80
            443
          ];
        };

        wireguard = {
          interfaces = {
            wg0 = {
              type = "wireguard";
              ips = [
                "${cfg.intranets.ingress.hub.intraIpAddress}/24"
              ];
              listenPort = 51820;
              privateKeyFile = config.age.secrets.interconnect-wireguard-ingress-hub.path;
              generatePrivateKeyFile = false;
              peers = [
                {
                  publicKey = "XASMyK2E6Jluj1jjsWc4eNXOA5OwjW3E5HlCCocK/BE=";
                  allowedIPs = [
                    "${cfg.intranets.ingress.spoke.intraIpAddress}/32"
                  ];
                }
              ];
            };
          };
        };

      };

    })

    (lib.mkIf cfg.intranets.ingress.spoke.claimed {

      age.secrets = {
        interconnect-wireguard-ingress-spoke = {
          rekeyFile = ./ingress.spoke.age;
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };

      networking = {

        firewall.extraInputRules = "iifname \"wg0\" ip saddr ${cfg.intranets.ingress.hub.intraIpAddress} accept";

        wireguard = {
          interfaces = {
            wg0 = {
              type = "wireguard";
              ips = [
                "${cfg.intranets.ingress.spoke.intraIpAddress}/24"
              ];
              privateKeyFile = config.age.secrets.interconnect-wireguard-ingress-spoke.path;
              generatePrivateKeyFile = false;
              peers = [
                {
                  publicKey = "NR1Zb8NAO2TpywtE9uZsftU8EWytnUWwOlVMDppZuww=";
                  allowedIPs = [
                    "${cfg.intranets.ingress.hub.intraIpAddress}/32"
                  ];
                  endpoint = "${cfg.intranets.ingress.hub.publicIpAddress}:51820";
                  persistentKeepalive = 25;
                }
              ];
            };
          };
        };

      };

    })

  ]);

}
