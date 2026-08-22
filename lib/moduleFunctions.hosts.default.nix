{ lib } : rec {

  getUniqueEnabledHost = hosts_ : let
    enabledHostEntries_ = (builtins.filter
      (hostEntry_ : (hostEntry_.value.enable or false) == true)
      (lib.mapAttrsToList
        (name_ : value_ : {
          name = name_;
          value = value_;
        })
        hosts_
      )
    );
  in (
    if (builtins.length enabledHostEntries_) == 1
    then (builtins.head enabledHostEntries_).value
    else builtins.throw "getUniqueEnabledHost requires exactly one enabled host. Enabled hosts: ${builtins.concatStringsSep ", " (builtins.map (hostEntry_ : hostEntry_.name) enabledHostEntries_)}."
  );

  mkWireGuardNetworks = { registry, privateKeyFile, wgIpRule, wgNameRule } : let

    hosts_ = registry;

    privateKeyFile_ = privateKeyFile;

    wgIpRule_ = wgIpRule;

    wgNameRule_ = wgNameRule;

  in let

    enabledHost_ = getUniqueEnabledHost hosts_;

    wireguardHosts_ = (lib.filterAttrs
      (unused_name_ : host_ : host_.wireguard != null)
      hosts_
    );

    networks_ = (lib.mapAttrs'
      (unused_name_ : endpointHost_ : {
        name = builtins.toString endpointHost_.number;
        value = {
          name = wgNameRule_ endpointHost_.number;
          nodes = (lib.mapAttrs'
            (unused_name_ : host_ : {
              name = builtins.toString host_.number;
              value = {
                ip = wgIpRule_
                  endpointHost_.number
                  host_.number;
                publicKey = host_.wireguard.publicKey;
                listenPort = host_.wireguard.listenPort;
                endpoint = host_.wireguard.endpoint;
              };
            })
            wireguardHosts_
          );
        };
      })
      (lib.filterAttrs
        (unused_name_ : host_ : host_.wireguard.endpoint != null)
        wireguardHosts_
      )
    );

  in {

    topology = (lib.mapAttrs
      (unused_networkNumber_ : network_ : {
        name = network_.name;
        nodes = (lib.mapAttrs
          (unused_hostNumber_ : node_ :
            node_.ip
          )
          network_.nodes
        );
      })
      networks_
    );

    config = (lib.optionalAttrs
      (enabledHost_.wireguard != null)
      (let

        enabledHostNumber_ = builtins.toString enabledHost_.number;

        wgConfigRule_ = self_ : peers_ : {

          ips = [
            "${self_.ip}/24"
          ];

          listenPort = self_.listenPort;

          peers = (builtins.map
            (peer_ : {

              publicKey = peer_.publicKey;

              allowedIPs = [
                "${peer_.ip}/32"
              ];

              endpoint = (
                if peer_.endpoint == null
                then null
                else let
                  address_ = (
                    if (builtins.match ".*:.*" peer_.endpoint.address) != null
                    then "[${peer_.endpoint.address}]"
                    else peer_.endpoint.address
                  );
                in "${address_}:${builtins.toString peer_.endpoint.port}"
              );

              persistentKeepalive = (
                if peer_.endpoint == null
                then null
                else 25
              );

            })
            peers_
          );

        };

        interfaceOf_ = networkNumber_ : network_ : let

          selfNode_ = builtins.getAttr
            enabledHostNumber_
            network_.nodes;

          peerNodes_ = (
            if enabledHostNumber_ == networkNumber_
            then (lib.filterAttrs
              (hostNumber_ : unused_node_ :
                hostNumber_ != enabledHostNumber_
              )
              network_.nodes
            )
            else {
              ${networkNumber_} =
                builtins.getAttr
                  networkNumber_
                  network_.nodes;
            }
          );

          self_ = {
            ip = selfNode_.ip;

            listenPort = (
              if enabledHostNumber_ == networkNumber_
              then selfNode_.listenPort
              else null
            );
          };

          peers_ = (lib.mapAttrsToList
            (peerNumber_ : peerNode_ : {
              ip = peerNode_.ip;

              publicKey = peerNode_.publicKey;

              endpoint = (
                if peerNumber_ == networkNumber_
                then peerNode_.endpoint
                else null
              );
            })
            peerNodes_
          );

        in (lib.mergeAttrsList
          [

            ({
              type = "wireguard";
              privateKeyFile = privateKeyFile_;
              generatePrivateKeyFile = false;
            })

            (wgConfigRule_
              self_
              peers_
            )

          ]
        );

      in {

        wireguard = {
          enable = true;
          interfaces = (lib.mapAttrs'
            (networkNumber_ : network_ : {
              name = network_.name;
              value = interfaceOf_
                networkNumber_
                network_;
            })
            networks_
          );
        };

        firewall = (lib.optionalAttrs
          (builtins.all
            (x_ : x_)
            [
              (enabledHost_.wireguard.endpoint != null)
              (enabledHost_.wireguard.listenPort != null)
            ]
          )
          {
            allowedUDPPorts = [
              enabledHost_.wireguard.listenPort
            ];
          }
        );

      })
    );

  };

}
