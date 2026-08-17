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
                "10.100.0.1/24"
              ];
              listenPort = 51820;
              privateKeyFile = config.age.secrets.interconnect-wireguard-ingress-hub.path;
              generatePrivateKeyFile = false;
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

        wireguard = {
          interfaces = {
            wg0 = {
              type = "wireguard";
              ips = [
                "10.100.0.2/24"
              ];
              privateKeyFile = config.age.secrets.interconnect-wireguard-ingress-spoke.path;
              generatePrivateKeyFile = false;
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

      };

    })

  ]);

}
