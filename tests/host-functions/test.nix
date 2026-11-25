{
  lib,
  runCommand,
  hosts,
  modules,
}:
let

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
      inherit registry;
      hostName = enabledHostName;
      privateKeyFile = "/run/wireguard-key";
      wgIpRule = hub: node: "10.100.${builtins.toString hub}.${builtins.toString node}";
      wgSubnetRule = hub: "10.100.${builtins.toString hub}.0/24";
      wgNameRule = number: "wg${builtins.toString number}";
    };

  singleHubRegistry_ = builtins.removeAttrs wireguardHosts_ [ "backup" ];
  noHubRegistry_ = builtins.removeAttrs wireguardHosts_ [
    "aliyun"
    "backup"
  ];

  topology_ = hosts.mkWireGuardTopology { registry = wireguardHosts_; };
  singleHubTopology_ = hosts.mkWireGuardTopology { registry = singleHubRegistry_; };
  noHubTopology_ = hosts.mkWireGuardTopology { registry = noHubRegistry_; };

  singleHub_ = mkNetworks_ singleHubRegistry_ "thinkbook";
  thinkbook_ = mkNetworks_ wireguardHosts_ "thinkbook";
  aliyun_ = mkNetworks_ wireguardHosts_ "aliyun";
  backup_ = mkNetworks_ wireguardHosts_ "backup";
  matebook_ = mkNetworks_ wireguardHosts_ "matebook";
  noHub_ = mkNetworks_ noHubRegistry_ "thinkbook";

  evalFirewall_ =
    {
      registry ? wireguardHosts_,
      hostName ? "aliyun",
      restrictOutput ? true,
      caddy ? true,
      extraRules ? [ ],
    }:
    (lib.evalModules {
      specialArgs = {
        llib.hosts = hosts;
        host = registry.${hostName} // {
          name = hostName;
          wireguard =
            if registry.${hostName}.wireguard == null then
              null
            else
              registry.${hostName}.wireguard // { privateKey = "/fixture/wireguard-key"; };
        };
        hostRegistry = registry;
        hostTopology = hosts.mkWireGuardTopology { inherit registry; };
        pkgs = { };
      };
      modules = [
        (modules + "/base/os/wireguard.nix")
        (modules + "/workloads/caddy/os/default.nix")
        {
          options = {
            assertions = lib.mkOption { type = lib.types.listOf lib.types.anything; };
            boot.kernel.sysctl = lib.mkOption { type = lib.types.attrsOf lib.types.anything; };
            age.secrets = lib.mkOption { type = lib.types.attrsOf lib.types.anything; };
            networking = {
              wireguard.enable = lib.mkEnableOption "fixture WireGuard";
              wireguard.interfaces = lib.mkOption { type = lib.types.attrsOf lib.types.anything; };
              firewall.allowedUDPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; };
              nftables.enable = lib.mkEnableOption "fixture nftables";
              nftables.tables = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule {
                    options = {
                      family = lib.mkOption { type = lib.types.str; };
                      content = lib.mkOption { type = lib.types.lines; };
                    };
                  }
                );
                default = { };
              };
            };
            ids.uids.caddy = lib.mkOption { type = lib.types.int; };
            containers = lib.mkOption { type = lib.types.attrsOf lib.types.anything; };
          };
          config = {
            base.wireguard.firewall.restrictOutput = restrictOutput;
            networking.nftables.enable = true;
            age.secrets.wireguard.path = "/run/wireguard-key";
            ids.uids.caddy = 239;
            workloads.caddy = lib.mkMerge [
              { enable = caddy; }
              (lib.mkIf caddy {
                ip = "10.100.3.2";
                port = 18000;
                networkInterface = "wg3";
              })
            ];
          };
        }
      ]
      ++ builtins.map (rule: { base.wireguard.firewall.extraOutputAllowRules = rule; }) extraRules;
    }).config;

  firewall_ = evalFirewall_ { extraRules = [ extraAllow_ ]; };
  unrestricted_ = evalFirewall_ { restrictOutput = false; };
  withoutCaddy_ = evalFirewall_ { caddy = false; };
  excludedFirewall_ = evalFirewall_ { hostName = "excluded"; };
  noHubFirewall_ = evalFirewall_ {
    registry = noHubRegistry_;
    hostName = "thinkbook";
  };

  hostOutput_ = firewall_.networking.nftables.tables.wireguard-egress.content;
  caddyOutput_ = firewall_.networking.nftables.tables.workload-caddy-egress.content;
  caddyAllow_ = ''meta skuid 239 oifname "wg3" ip daddr 10.100.3.2 tcp dport 18000 accept'';
  extraAllow_ = ''oifname "wg5" ip daddr 10.100.5.4 tcp dport 1234 accept'';

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
      specialArgs = {
        llib.hosts = hosts;
        host = sshRegistry_.${enabledHostName_};
        hostRegistry = sshRegistry_;
      };
      modules = [
        (modules + "/base/os/ssh-targets.nix")
        {
          options = {
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
    (mkNetworks_ wireguardHosts_ "excluded" == { })

    (
      hosts.getManagedWireGuardInterfaces {
        topology = topology_;
        hostName = "aliyun";
      } == [
        "wg3"
        "wg5"
      ]
    )
    (
      hosts.getManagedWireGuardInterfaces {
        topology = singleHubTopology_;
        hostName = "thinkbook";
      } == [ "wg3" ]
    )
    (
      hosts.getManagedWireGuardInterfaces {
        topology = topology_;
        hostName = "excluded";
      } == [ ]
    )
    (
      hosts.getManagedWireGuardInterfaces {
        topology = noHubTopology_;
        hostName = "thinkbook";
      } == [ ]
    )
    (lib.hasInfix ''oifname { "wg3", "wg5" } jump restricted-output'' hostOutput_)
    (lib.hasInfix ''meta skuid 239 oifname { "wg3", "wg5" } jump restricted-output'' caddyOutput_)
    (lib.hasInfix caddyAllow_ hostOutput_)
    (lib.hasInfix extraAllow_ hostOutput_)
    (!lib.hasInfix extraAllow_ caddyOutput_)
    (lib.hasInfix ''oifname "wg3" ip daddr 10.100.3.2 tcp dport 18000 accept'' caddyOutput_)
    (builtins.all (content: lib.hasInfix "ct direction reply ct state established accept" content) [
      hostOutput_
      caddyOutput_
    ])
    (builtins.all
      (
        content:
        lib.hasInfix "ct direction reply ct state related meta l4proto { icmp, ipv6-icmp } accept" content
      )
      [
        hostOutput_
        caddyOutput_
      ]
    )
    (lib.hasInfix "${firewall_.base.wireguard.firewall.extraOutputAllowRules}\n\n  reject" hostOutput_)
    (!(unrestricted_.networking.nftables.tables ? wireguard-egress))
    (unrestricted_.networking.nftables.tables.workload-caddy-egress.content == caddyOutput_)
    (withoutCaddy_.base.wireguard.firewall.extraOutputAllowRules == "")
    (withoutCaddy_.networking.nftables.tables ? wireguard-egress)
    (!(withoutCaddy_.networking.nftables.tables ? workload-caddy-egress))
    (excludedFirewall_.networking.nftables.tables == { })
    (noHubFirewall_.networking.nftables.tables == { })
    (firewall_.networking.nftables.tables.wireguard-isolation.content == isolationRules_ aliyun_)

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
    (builtins.attrNames singleHubTopology_ == [ "aliyun" ])
    (builtins.attrNames singleHub_.wireguard.interfaces == [ "wg3" ])
    (noHubTopology_ == { })
    (noHub_.nftables.tables == { })
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
        topology = singleHubTopology_;
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
