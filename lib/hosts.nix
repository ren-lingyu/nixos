{ lib }: rec {
  getUniqueEnabledHostEntry =
    hosts_:
    let
      enabledHostEntries_ = (
        builtins.filter (hostEntry_: (hostEntry_.value.enable or false) == true) (
          lib.mapAttrsToList (name_: value_: {
            name = name_;
            value = value_;
          }) hosts_
        )
      );
    in
    (
      if (builtins.length enabledHostEntries_) == 1 then
        builtins.head enabledHostEntries_
      else
        builtins.throw "Exactly one enabled host is required. Enabled hosts: ${
          builtins.concatStringsSep ", " (builtins.map (hostEntry_: hostEntry_.name) enabledHostEntries_)
        }."
    );

  getUniqueEnabledHost = hosts_: (getUniqueEnabledHostEntry hosts_).value;

  mkWireGuardNetworks =
    {
      registry,
      privateKeyFile,
      wgIpRule,
      wgSubnetRule,
      wgNameRule,
    }:
    let

      hosts_ = registry;

      privateKeyFile_ = privateKeyFile;

      wgIpRule_ = wgIpRule;

      wgSubnetRule_ = wgSubnetRule;

      wgNameRule_ = wgNameRule;

    in
    let

      enabledHostEntry_ = getUniqueEnabledHostEntry hosts_;

      enabledHost_ = enabledHostEntry_.value;

      wireguardHosts_ = (lib.filterAttrs (unused_name_: host_: host_.wireguard != null) hosts_);

      networks_ = (
        lib.mapAttrs (_: endpointHost_: {
          number = endpointHost_.number;
          name = wgNameRule_ endpointHost_.number;
          subnet = wgSubnetRule_ endpointHost_.number;
          nodes = (
            lib.mapAttrs (_: host_: {
              number = host_.number;
              ip = wgIpRule_ endpointHost_.number host_.number;
              publicKey = host_.wireguard.publicKey;
              listenPort = host_.wireguard.listenPort;
              endpoint = host_.wireguard.endpoint;
            }) wireguardHosts_
          );
        }) (lib.filterAttrs (_: host_: host_.wireguard.endpoint != null) wireguardHosts_)
      );

    in
    {
      topology = (
        lib.mapAttrs (unused_networkNumber_: network_: {
          name = network_.name;
          subnet = network_.subnet;
          nodes = (lib.mapAttrs (unused_hostNumber_: node_: node_.ip) network_.nodes);
        }) networks_
      );

      config = (
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

                selfNode_ = builtins.getAttr enabledHostEntry_.name network_.nodes;

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
                  privateKeyFile = privateKeyFile_;
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
        )
      );
    };
}
