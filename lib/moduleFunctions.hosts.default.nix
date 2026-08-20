{ lib } : rec {

  getUniqueEnabledHost = hosts_ : let
    enabledHosts_ = (lib.filterAttrs
      (unused_name_ : host_ : (host_.enable or false) == true)
      hosts_
    );
    enabledHostNames_ = builtins.attrNames enabledHosts_;
  in (
    if (builtins.length enabledHostNames_) == 1
    then enabledHosts_.${builtins.head enabledHostNames_}
    else builtins.throw "getUniqueEnabledHost requires exactly one enabled host. Enabled hosts: ${builtins.concatStringsSep ", " enabledHostNames_}."
  );

  mkWireGuardNetworking = { registry, privateKeyFile, wgIpRule, wgNameRule } : let

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

    hubHosts_ = (lib.filterAttrs
      (unused_name_ : host_ : host_.wireguard.endpoint != null)
      wireguardHosts_
    );

    otherWireguardHosts_ = (lib.filterAttrs
      (unused_name_ : host_ : !(host_.enable or false))
      wireguardHosts_
    );

    interfaceNameOf_ = hubHost_ : wgNameRule_ hubHost_.number;

    intraIpAddressOf_ = hubHost_ : host_ : wgIpRule_ hubHost_.number host_.number;

    endpointOf_ = host_ : let
      endpoint_ = host_.wireguard.endpoint;
      address_ = (
        if (builtins.match ".*:.*" endpoint_.address) != null
        then "[${endpoint_.address}]"
        else endpoint_.address
      );
    in "${address_}:${builtins.toString endpoint_.port}";

    peerOf_ = hubHost_ : host_ : (lib.mergeAttrsList
      [

        ({
          publicKey = host_.wireguard.publicKey;
          allowedIPs = [
            "${intraIpAddressOf_ hubHost_ host_}/32"
          ];
        })

        (lib.optionalAttrs
          (host_.number == hubHost_.number)
          {
            endpoint = endpointOf_ hubHost_;
            persistentKeepalive = 25;
          }
        )

      ]
    );

    interfaceOf_ = hubHost_ : peerHosts_ : (lib.mergeAttrsList
      [

        ({
          type = "wireguard";
          ips = [
            "${intraIpAddressOf_ hubHost_ enabledHost_}/24"
          ];
          privateKeyFile = privateKeyFile_;
          generatePrivateKeyFile = false;
          peers = builtins.map
            (host_ : peerOf_ hubHost_ host_)
            peerHosts_;
        })

        (lib.optionalAttrs
          (builtins.all
            (x_ : x_)
            [
              (enabledHost_.number == hubHost_.number)
              (enabledHost_.wireguard.listenPort != null)
            ]
          )
          {
            listenPort = enabledHost_.wireguard.listenPort;
          }
        )

      ]
    );

    interfaces_ = (lib.mapAttrs'
      (unused_name_ : hubHost_ : {
        name = interfaceNameOf_ hubHost_;
        value = (interfaceOf_
          hubHost_
          (
            if enabledHost_.number == hubHost_.number
            then builtins.attrValues otherWireguardHosts_
            else [
              hubHost_
            ]
          )
        );
      })
      hubHosts_
    );

  in (lib.optionalAttrs
    (enabledHost_.wireguard != null)
    {

      wireguard = {
        enable = true;
        interfaces = interfaces_;
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

    }
  );

}
