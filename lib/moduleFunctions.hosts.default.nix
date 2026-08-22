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
      (unused_name_ : hubHost_ : {
        name = builtins.toString hubHost_.number;
        value = {
          name = wgNameRule_ hubHost_.number;
          nodes = (lib.mapAttrs'
            (unused_name_ : host_ : {
              name = builtins.toString host_.number;
              value = {
                ip = wgIpRule_
                  hubHost_.number
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

        endpointOf_ = endpoint_ : let
          address_ = (
            if (builtins.match ".*:.*" endpoint_.address) != null
            then "[${endpoint_.address}]"
            else endpoint_.address
          );
        in "${address_}:${builtins.toString endpoint_.port}";

        peerOf_ = networkNumber_ : peerNumber_ : peerNode_ :
        (lib.mergeAttrsList
          [

            ({
              publicKey = peerNode_.publicKey;

              allowedIPs = [
                "${peerNode_.ip}/32"
              ];
            })

            (lib.optionalAttrs
              (peerNumber_ == networkNumber_)
              {
                endpoint = endpointOf_ peerNode_.endpoint;
                persistentKeepalive = 25;
              }
            )

          ]
        );

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

        in (lib.mergeAttrsList
          [

            ({
              type = "wireguard";
              ips = [
                "${selfNode_.ip}/24"
              ];
              privateKeyFile = privateKeyFile_;
              generatePrivateKeyFile = false;
              peers = (lib.mapAttrsToList
                (peerNumber_ : peerNode_ :
                peerOf_
                  networkNumber_
                  peerNumber_
                  peerNode_
                )
                peerNodes_
              );
            })

            (lib.optionalAttrs
              (builtins.all
                (x_ : x_)
                [
                  (enabledHostNumber_ == networkNumber_)
                  (selfNode_.listenPort != null)
                ]
              )
              {
                listenPort = selfNode_.listenPort;
              }
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
