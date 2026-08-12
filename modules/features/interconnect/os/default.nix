{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.interconnect;

in {

  config = lib.mkIf cfg.enable {

    networking = lib.mkMerge [

      {

        wireguard.enable = true;

      }

      (lib.mkIf cfg.intranets.ingress.hub.claimed {

        firewall = {
          allowedUDPPorts = [
            51820
          ];
        };

        wireguard = {
          interfaces = {
            wg0 = {
              type = "wireguard";
              ips = [
                "10.100.0.1/24"
              ];
              listenPort = 51820;
              privateKeyFile = "/var/lib/wireguard/wg0-private-key";
              generatePrivateKeyFile = true;
              peers = [
                {
                  publicKey = "XASMyK2E6Jluj1jjsWc4eNXOA5OwjW3E5HlCCocK/BE=";
                  allowedIPs = [
                    "10.100.0.2/32"
                  ];
                }
              ];
            };
          };
        };

      })

      (lib.mkIf cfg.intranets.ingress.spoke.claimed {

        wireguard = {
          interfaces = {
            wg0 = {
              type = "wireguard";
              ips = [
                "10.100.0.2/24"
              ];
              privateKeyFile = "/var/lib/wireguard/wg0-private-key";
              generatePrivateKeyFile = true;
              peers = [
                {
                  publicKey = "NR1Zb8NAO2TpywtE9uZsftU8EWytnUWwOlVMDppZuww=";
                  allowedIPs = [
                    "10.100.0.1/32"
                  ];
                  endpoint = "${cfg.intranets.ingress.hub.ip}:51820";
                  persistentKeepalive = 25;
                }
              ];
            };
          };
        };

      })

    ];

  };

}
