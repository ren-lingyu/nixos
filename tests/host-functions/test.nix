{
  lib,
  runCommand,
  hosts,
  modules,
}:
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

  sshRegistry_ = lib.mapAttrs (
    name_: host_:
    host_
    // {
      identity.keys.ssh.public.key =
        if name_ == "excluded" then null else "ssh-ed25519 ${name_}-host-key";
    }
  ) wireguardHosts_;

  mkNetworks_ =
    registry: enabledHostName:
    hosts.mkWireGuardNetworks {
      registry = builtins.mapAttrs (name: host: host // { enable = name == enabledHostName; }) registry;
      privateKeyFile = "/run/wireguard-key";
      wgIpRule = hub: node: "10.100.${builtins.toString hub}.${builtins.toString node}";
      wgSubnetRule = hub: "10.100.${builtins.toString hub}.0/24";
      wgNameRule = number: "wg${builtins.toString number}";
    };

  topology_ = (mkNetworks_ wireguardHosts_ "thinkbook").topology;
  singleHub_ = mkNetworks_ (builtins.removeAttrs wireguardHosts_ [ "backup" ]) "thinkbook";
  thinkbook_ = (mkNetworks_ wireguardHosts_ "thinkbook").config;
  aliyun_ = (mkNetworks_ wireguardHosts_ "aliyun").config;
  backup_ = (mkNetworks_ wireguardHosts_ "backup").config;
  matebook_ = (mkNetworks_ wireguardHosts_ "matebook").config;
  noHub_ = mkNetworks_ (builtins.removeAttrs wireguardHosts_ [
    "aliyun"
    "backup"
  ]) "thinkbook";

  sshTargets_ = hosts.mkWireGuardSshTargets {
    registry = sshRegistry_;
    topology = topology_;
  };

  missingKeySshTargets_ = hosts.mkWireGuardSshTargets {
    registry = sshRegistry_ // {
      matebook = sshRegistry_.matebook // {
        identity.keys.ssh.public.key = null;
      };
    };
    topology = topology_;
  };

  evalSshModule_ =
    enabledHostName_:
    (lib.evalModules {
      specialArgs.llib.hosts = hosts;
      modules = [
        (modules + "/hosts/ssh-targets.nix")
        {
          options = {
            modules.hosts = lib.mkOption { type = lib.types.attrsOf lib.types.anything; };
            networking.wireguard.topology = lib.mkOption { type = lib.types.attrsOf lib.types.anything; };
            programs.ssh.hosts = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = { };
            };
            programs.ssh.knownHosts = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = { };
            };
          };
          config = {
            modules.hosts = lib.mapAttrs (
              name_: host_: host_ // { enable = name_ == enabledHostName_; }
            ) sshRegistry_;
            networking.wireguard.topology = topology_;
          };
        }
      ];
    }).config.programs.ssh;

  isolationRules_ = config: config.nftables.tables."wireguard-isolation".content;

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
          subnet = "10.100.3.0/24";
          nodes = {
            aliyun = "10.100.3.3";
            backup = "10.100.3.5";
            matebook = "10.100.3.4";
            thinkbook = "10.100.3.2";
          };
        };
        backup = {
          name = "wg5";
          subnet = "10.100.5.0/24";
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
    (noHub_.topology == { })
    (noHub_.config.nftables.tables == { })
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
          allowedIPs = [ "10.100.3.0/24" ];
          endpoint = "203.0.113.3:51820";
          persistentKeepalive = 25;
        }
      ]
    )
    (
      thinkbook_.wireguard.interfaces.wg5.peers == [
        {
          publicKey = "key-backup";
          allowedIPs = [ "10.100.5.0/24" ];
          endpoint = "[2001:db8::5]:51821";
          persistentKeepalive = 25;
        }
      ]
    )
    (!thinkbook_.wireguard.interfaces.wg3.allowedIPsAsRoutes)
    (!thinkbook_.wireguard.interfaces.wg5.allowedIPsAsRoutes)
    (!matebook_.wireguard.interfaces.wg3.allowedIPsAsRoutes)
    (thinkbook_.wireguard.interfaces.wg3.privateKeyFile == "/run/wireguard-key")
    (thinkbook_.wireguard.interfaces.wg3.generatePrivateKeyFile == false)

    (aliyun_.wireguard.interfaces.wg3.ips == [ "10.100.3.3/24" ])
    (aliyun_.wireguard.interfaces.wg3.listenPort == 51820)
    (aliyun_.wireguard.interfaces.wg3.allowedIPsAsRoutes)
    (peersByKey_ aliyun_.wireguard.interfaces.wg3.peers == expectedHubPeers_)
    (aliyun_.wireguard.interfaces.wg5.listenPort == null)
    (!aliyun_.wireguard.interfaces.wg5.allowedIPsAsRoutes)
    (
      aliyun_.wireguard.interfaces.wg5.peers == [
        {
          publicKey = "key-backup";
          allowedIPs = [ "10.100.5.0/24" ];
          endpoint = "[2001:db8::5]:51821";
          persistentKeepalive = 25;
        }
      ]
    )
    (backup_.wireguard.interfaces.wg5.listenPort == 51821)
    (backup_.wireguard.interfaces.wg5.allowedIPsAsRoutes)
    (!backup_.wireguard.interfaces.wg3.allowedIPsAsRoutes)
    (builtins.length backup_.wireguard.interfaces.wg5.peers == 3)
    (
      (peersByKey_ backup_.wireguard.interfaces.wg5.peers)."key-aliyun".allowedIPs == [ "10.100.5.3/32" ]
    )
    (aliyun_.firewall.allowedUDPPorts == [ 51820 ])
    (backup_.firewall.allowedUDPPorts == [ 51821 ])
    (!(thinkbook_.firewall ? allowedUDPPorts))

    (lib.hasInfix ''iifname "wg3" oifname "wg3" meta nfproto ipv4 accept'' (isolationRules_ aliyun_))
    (!lib.hasInfix ''iifname "wg5" oifname "wg5" meta nfproto ipv4 accept'' (isolationRules_ aliyun_))
    (lib.hasInfix ''iifname "wg5" oifname "wg5" meta nfproto ipv4 accept'' (isolationRules_ backup_))
    (!lib.hasInfix ''iifname "wg3" oifname "wg3" meta nfproto ipv4 accept'' (isolationRules_ backup_))
    (!lib.hasInfix "meta nfproto ipv4 accept" (isolationRules_ thinkbook_))
    (lib.hasInfix ''iifname { "wg3", "wg5" } drop'' (isolationRules_ aliyun_))
    (lib.hasInfix ''oifname { "wg3", "wg5" } drop'' (isolationRules_ thinkbook_))
    (lib.hasInfix "priority -10; policy accept;" (isolationRules_ matebook_))

    (builtins.length (builtins.attrNames sshTargets_.hosts) == 8)
    (builtins.length (builtins.attrNames sshTargets_.knownHosts) == 4)
    (
      sshTargets_.hosts."aliyun.thinkbook" == {
        order = 1000;
        HostName = "10.100.3.2";
        HostKeyAlias = "wg-host-thinkbook";
      }
    )
    (sshTargets_.hosts."aliyun.aliyun".order == 1001)
    (sshTargets_.hosts."aliyun.matebook".order == 1002)
    (sshTargets_.hosts."aliyun.backup".order == 1003)
    (sshTargets_.hosts."backup.thinkbook".order == 1004)
    (sshTargets_.hosts."backup.matebook".order == 1006)
    (sshTargets_.hosts."backup.matebook".HostName == "10.100.5.4")
    (
      sshTargets_.hosts."backup.matebook".HostKeyAlias == sshTargets_.hosts."aliyun.matebook".HostKeyAlias
    )
    (sshTargets_.knownHosts."wg-host-matebook".publicKey == "ssh-ed25519 matebook-host-key")
    (
      builtins.attrNames sshTargets_.knownHosts == [
        "wg-host-aliyun"
        "wg-host-backup"
        "wg-host-matebook"
        "wg-host-thinkbook"
      ]
    )
    (builtins.all (
      settings_:
      builtins.attrNames settings_ == [
        "HostKeyAlias"
        "HostName"
        "order"
      ]
    ) (builtins.attrValues sshTargets_.hosts))
    (
      hosts.mkWireGuardSshTargets {
        registry = sshRegistry_;
        topology = { };
      } == {
        hosts = { };
        knownHosts = { };
      }
    )
    (
      (hosts.mkWireGuardSshTargets {
        registry = sshRegistry_;
        topology = singleHub_.topology;
        baseOrder = 1200;
      }).hosts."aliyun.thinkbook".order == 1200
    )
    (!(builtins.tryEval (builtins.deepSeq missingKeySshTargets_.knownHosts true)).success)
    ((evalSshModule_ "thinkbook").hosts == sshTargets_.hosts)
    ((evalSshModule_ "thinkbook").knownHosts == sshTargets_.knownHosts)
    (
      (evalSshModule_ "excluded") == {
        hosts = { };
        knownHosts = { };
      }
    )
  ];

in
assert builtins.all (check: check) checks_;
runCommand "nixos-host-functions" { } ''
  touch $out
''
