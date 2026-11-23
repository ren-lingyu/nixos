{ runCommand, hosts }:
let

  hosts_ = {
    disabled = {
      enable = false;
      value = "disabled";
    };
    enabled = {
      enable = true;
      value = "enabled";
    };
  };

  noEnabledHosts_ = {
    disabled.enable = false;
  };

  multipleEnabledHosts_ = {
    first.enable = true;
    second.enable = true;
  };

  wireguardHosts_ = {
    aliyun = {
      number = 3;
      wireguard = {
        publicKey = "key-aliyun";
        listenPort = 51820;
        endpoint = {
          address = "203.0.113.3";
          port = 51820;
        };
      };
    };
    backup = {
      number = 5;
      wireguard = {
        publicKey = "key-backup";
        listenPort = 51821;
        endpoint = {
          address = "2001:db8::5";
          port = 51821;
        };
      };
    };
    thinkbook = {
      number = 2;
      wireguard = {
        publicKey = "key-thinkbook";
        listenPort = null;
        endpoint = null;
      };
    };
    matebook = {
      number = 4;
      wireguard = {
        publicKey = "key-matebook";
        listenPort = null;
        endpoint = null;
      };
    };
    excluded = {
      number = 9;
      wireguard = null;
    };
  };

  mkNetworks_ =
    registry: enabledHostName:
    hosts.mkWireGuardNetworks {
      registry = builtins.mapAttrs (name: host: host // { enable = name == enabledHostName; }) registry;
      privateKeyFile = "/run/wireguard-key";
      wgIpRule = hub: node: "10.100.${builtins.toString hub}.${builtins.toString node}";
      wgNameRule = number: "wg${builtins.toString number}";
    };

  topology_ = (mkNetworks_ wireguardHosts_ "thinkbook").topology;
  singleHub_ = mkNetworks_ (builtins.removeAttrs wireguardHosts_ [ "backup" ]) "thinkbook";
  thinkbook_ = (mkNetworks_ wireguardHosts_ "thinkbook").config;
  aliyun_ = (mkNetworks_ wireguardHosts_ "aliyun").config;
  backup_ = (mkNetworks_ wireguardHosts_ "backup").config;

  peersByKey_ =
    peers:
    builtins.listToAttrs (
      builtins.map (peer: {
        name = peer.publicKey;
        value = peer;
      }) peers
    );

  expectedHubPeers_ = {
    "key-backup" = {
      publicKey = "key-backup";
      allowedIPs = [ "10.100.3.5/32" ];
      endpoint = null;
      persistentKeepalive = null;
    };
    "key-thinkbook" = {
      publicKey = "key-thinkbook";
      allowedIPs = [ "10.100.3.2/32" ];
      endpoint = null;
      persistentKeepalive = null;
    };
    "key-matebook" = {
      publicKey = "key-matebook";
      allowedIPs = [ "10.100.3.4/32" ];
      endpoint = null;
      persistentKeepalive = null;
    };
  };

  checks_ = [
    ((hosts.getUniqueEnabledHostEntry hosts_).name == "enabled")
    ((hosts.getUniqueEnabledHostEntry hosts_).value.value == "enabled")
    ((hosts.getUniqueEnabledHost hosts_).value == "enabled")
    (!(builtins.tryEval (hosts.getUniqueEnabledHost noEnabledHosts_)).success)
    (!(builtins.tryEval (hosts.getUniqueEnabledHost multipleEnabledHosts_)).success)
    (!(builtins.tryEval (hosts.getUniqueEnabledHostEntry noEnabledHosts_)).success)
    (!(builtins.tryEval (hosts.getUniqueEnabledHostEntry multipleEnabledHosts_)).success)

    (
      topology_ == {
        aliyun = {
          name = "wg3";
          nodes = {
            aliyun = "10.100.3.3";
            backup = "10.100.3.5";
            matebook = "10.100.3.4";
            thinkbook = "10.100.3.2";
          };
        };
        backup = {
          name = "wg5";
          nodes = {
            aliyun = "10.100.5.3";
            backup = "10.100.5.5";
            matebook = "10.100.5.4";
            thinkbook = "10.100.5.2";
          };
        };
      }
    )
    (builtins.attrNames singleHub_.topology == [ "aliyun" ])
    (builtins.attrNames singleHub_.config.wireguard.interfaces == [ "wg3" ])
    (
      builtins.attrNames thinkbook_.wireguard.interfaces == [
        "wg3"
        "wg5"
      ]
    )
    (
      builtins.attrNames aliyun_.wireguard.interfaces == [
        "wg3"
        "wg5"
      ]
    )

    (thinkbook_.wireguard.interfaces.wg3.ips == [ "10.100.3.2/24" ])
    (thinkbook_.wireguard.interfaces.wg3.listenPort == null)
    (
      thinkbook_.wireguard.interfaces.wg3.peers == [
        {
          publicKey = "key-aliyun";
          allowedIPs = [ "10.100.3.3/32" ];
          endpoint = "203.0.113.3:51820";
          persistentKeepalive = 25;
        }
      ]
    )
    (
      thinkbook_.wireguard.interfaces.wg5.peers == [
        {
          publicKey = "key-backup";
          allowedIPs = [ "10.100.5.5/32" ];
          endpoint = "[2001:db8::5]:51821";
          persistentKeepalive = 25;
        }
      ]
    )
    (thinkbook_.wireguard.interfaces.wg3.privateKeyFile == "/run/wireguard-key")
    (thinkbook_.wireguard.interfaces.wg3.generatePrivateKeyFile == false)

    (aliyun_.wireguard.interfaces.wg3.ips == [ "10.100.3.3/24" ])
    (aliyun_.wireguard.interfaces.wg3.listenPort == 51820)
    (peersByKey_ aliyun_.wireguard.interfaces.wg3.peers == expectedHubPeers_)
    (aliyun_.wireguard.interfaces.wg5.listenPort == null)
    (
      aliyun_.wireguard.interfaces.wg5.peers == [
        {
          publicKey = "key-backup";
          allowedIPs = [ "10.100.5.5/32" ];
          endpoint = "[2001:db8::5]:51821";
          persistentKeepalive = 25;
        }
      ]
    )
    (backup_.wireguard.interfaces.wg5.listenPort == 51821)
    (builtins.length backup_.wireguard.interfaces.wg5.peers == 3)
    (aliyun_.firewall.allowedUDPPorts == [ 51820 ])
    (backup_.firewall.allowedUDPPorts == [ 51821 ])
    (!(thinkbook_.firewall ? allowedUDPPorts))
  ];

in
assert builtins.all (check: check) checks_;
runCommand "nixos-host-functions" { } ''
  touch $out
''
