{ lib }: rec {
  getManagedWireGuardInterfaces =
    { topology, hostName }:
    lib.mapAttrsToList (_: network: network.name) (
      lib.filterAttrs (_: network: builtins.hasAttr hostName network.nodes) topology
    );

  mkWireGuardSshTargets =
    {
      registry,
      topology,
      baseOrder ? 1000,
    }:
    let
      entries_ = lib.concatMap (
        hubName_:
        lib.mapAttrsToList (nodeName_: ip_: {
          hub = hubName_;
          node = nodeName_;
          hubNumber = registry.${hubName_}.number;
          nodeNumber = registry.${nodeName_}.number;
          ip = ip_;
        }) topology.${hubName_}.nodes
      ) (builtins.attrNames topology);

      orderedEntries_ = lib.sort (
        a_: b_:
        a_.hubNumber < b_.hubNumber || (a_.hubNumber == b_.hubNumber && a_.nodeNumber < b_.nodeNumber)
      ) entries_;

      nodeNames_ = lib.unique (builtins.map (entry_: entry_.node) entries_);
    in
    {
      hosts = builtins.listToAttrs (
        lib.imap0 (index_: entry_: {
          name = "${entry_.hub}.${entry_.node}";
          value = {
            order = baseOrder + index_;
            HostName = entry_.ip;
            HostKeyAlias = "wg-host-${entry_.node}";
          };
        }) orderedEntries_
      );

      knownHosts = builtins.listToAttrs (
        builtins.map (
          nodeName_:
          let
            publicKey_ = registry.${nodeName_}.identity.keys.ssh.public.key or null;
          in
          assert lib.assertMsg (publicKey_ != null) (
            "Missing SSH host public key for WireGuard node `${nodeName_}`."
          );
          {
            name = "wg-host-${nodeName_}";
            value.publicKey = publicKey_;
          }
        ) nodeNames_
      );
    };

  wireguardRules = {
    wgIpRule = hub: node: "10.100.${toString hub}.${toString node}";
    wgSubnetRule = hub: "10.100.${toString hub}.0/24";
    wgNameRule = hub: "wg${toString hub}";
  };

  mkWireGuardNetworkData =
    {
      registry,
      wgIpRule ? wireguardRules.wgIpRule,
      wgSubnetRule ? wireguardRules.wgSubnetRule,
      wgNameRule ? wireguardRules.wgNameRule,
    }:
    let
      wireguardHosts_ = (lib.filterAttrs (unused_name_: host_: host_.wireguard != null) registry);

      networks_ = (
        lib.mapAttrs (_: endpointHost_: {
          number = endpointHost_.number;
          name = wgNameRule endpointHost_.number;
          subnet = wgSubnetRule endpointHost_.number;
          nodes = (
            lib.mapAttrs (_: host_: {
              number = host_.number;
              ip = wgIpRule endpointHost_.number host_.number;
              publicKey = host_.wireguard.publicKey;
              listenPort = host_.wireguard.listenPort;
              endpoint = host_.wireguard.endpoint;
            }) wireguardHosts_
          );
        }) (lib.filterAttrs (_: host_: host_.wireguard.endpoint != null) wireguardHosts_)
      );

    in
    networks_;

  mkWireGuardTopology =
    args:
    lib.mapAttrs (_: network: {
      inherit (network) name subnet;
      nodes = lib.mapAttrs (_: node: node.ip) network.nodes;
    }) (mkWireGuardNetworkData args);

  mkWireGuardNetworks =
    {
      registry,
      hostName,
      privateKeyFile,
      wgIpRule ? wireguardRules.wgIpRule,
      wgSubnetRule ? wireguardRules.wgSubnetRule,
      wgNameRule ? wireguardRules.wgNameRule,
    }:
    let
      enabledHost_ = registry.${hostName};
      networkArgs = {
        inherit
          registry
          wgIpRule
          wgSubnetRule
          wgNameRule
          ;
      };
      networks_ = mkWireGuardNetworkData networkArgs;
    in
    lib.optionalAttrs (enabledHost_.wireguard != null) (
      let

        interfaceNames_ = lib.mapAttrsToList (_: network_: network_.name) networks_;

        hubInterfaceNames_ = lib.mapAttrsToList (_: network_: network_.name) (
          lib.filterAttrs (_: network_: network_.number == enabledHost_.number) networks_
        );

        nftInterfaceSet_ = lib.concatMapStringsSep ", " (name_: ''"${name_}"'') interfaceNames_;

        wgConfigRule_ = self_: peers_: {
          ips = [ "${self_.ip}/${self_.prefixLength}" ];

          listenPort = self_.listenPort;

          peers = (
            builtins.map (peer_: {
              publicKey = peer_.publicKey;

              allowedIPs = peer_.allowedIPs;

              endpoint = (
                if peer_.endpoint == null then
                  null
                else
                  let
                    address_ = (
                      if (builtins.match ".*:.*" peer_.endpoint.address) != null then
                        "[${peer_.endpoint.address}]"
                      else
                        peer_.endpoint.address
                    );
                  in
                  "${address_}:${builtins.toString peer_.endpoint.port}"
              );

              persistentKeepalive = (if peer_.endpoint == null then null else 25);
            }) peers_
          );
        };

        interfaceOf_ =
          networkName_: network_:
          let

            selfNode_ = builtins.getAttr hostName network_.nodes;

            isHub_ = enabledHost_.number == network_.number;

            peerNodes_ = (
              if isHub_ then
                (lib.filterAttrs (_: node_: node_.number != enabledHost_.number) network_.nodes)
              else
                { ${networkName_} = builtins.getAttr networkName_ network_.nodes; }
            );

            self_ = {
              ip = selfNode_.ip;
              prefixLength = lib.last (lib.splitString "/" network_.subnet);

              listenPort = (if isHub_ then selfNode_.listenPort else null);
            };

            peers_ = (
              lib.mapAttrsToList (_: peerNode_: {
                publicKey = peerNode_.publicKey;

                allowedIPs = if isHub_ then [ "${peerNode_.ip}/32" ] else [ network_.subnet ];

                endpoint = (if peerNode_.number == network_.number then peerNode_.endpoint else null);
              }) peerNodes_
            );

          in
          (lib.mergeAttrsList [
            ({
              type = "wireguard";
              privateKeyFile = privateKeyFile;
              generatePrivateKeyFile = false;
              allowedIPsAsRoutes = isHub_;
            })

            (wgConfigRule_ self_ peers_)
          ]);

      in
      {
        wireguard = {
          enable = true;
          interfaces = (
            lib.mapAttrs' (networkName_: network_: {
              name = network_.name;
              value = interfaceOf_ networkName_ network_;
            }) networks_
          );
        };

        firewall = (
          lib.optionalAttrs (builtins.all (x_: x_) [
            (enabledHost_.wireguard.endpoint != null)
            (enabledHost_.wireguard.listenPort != null)
          ]) { allowedUDPPorts = [ enabledHost_.wireguard.listenPort ]; }
        );

        nftables.tables = lib.optionalAttrs (interfaceNames_ != [ ]) {
          "wireguard-isolation" = {
            family = "inet";
            content = ''
              chain forward {
                type filter hook forward priority -10; policy accept;

                # Only this host's Hub interfaces may forward within themselves.
                ${lib.concatMapStringsSep "\n" (
                  name_: ''iifname "${name_}" oifname "${name_}" meta nfproto ipv4 accept''
                ) hubInterfaceNames_}

                # Reject every other forwarded packet involving a managed WG interface.
                iifname { ${nftInterfaceSet_} } drop
                oifname { ${nftInterfaceSet_} } drop
              }
            '';
          };
        };
      }
    );
}
