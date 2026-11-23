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
      wgNameRule,
    }:
    let

      hosts_ = registry;

      privateKeyFile_ = privateKeyFile;

      wgIpRule_ = wgIpRule;

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
          nodes = (lib.mapAttrs (unused_hostNumber_: node_: node_.ip) network_.nodes);
        }) networks_
      );

      config = (
        lib.optionalAttrs (enabledHost_.wireguard != null) (
          let

            wgConfigRule_ = self_: peers_: {
              ips = [ "${self_.ip}/24" ];

              listenPort = self_.listenPort;

              peers = (
                builtins.map (peer_: {
                  publicKey = peer_.publicKey;

                  allowedIPs = [ "${peer_.ip}/32" ];

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

                  listenPort = (if isHub_ then selfNode_.listenPort else null);
                };

                peers_ = (
                  lib.mapAttrsToList (_: peerNode_: {
                    ip = peerNode_.ip;

                    publicKey = peerNode_.publicKey;

                    endpoint = (if peerNode_.number == network_.number then peerNode_.endpoint else null);
                  }) peerNodes_
                );

              in
              (lib.mergeAttrsList [
                ({
                  type = "wireguard";
                  privateKeyFile = privateKeyFile_;
                  generatePrivateKeyFile = false;
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
          }
        )
      );
    };
}
