{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.interconnect;

  hosts_ = config.modules.hosts;

  enabledHostNames_ = builtins.attrNames (lib.filterAttrs (unused_name_ : host_ : (
    host_.enable
  )) hosts_);

  claimantNamesOf_ = netName_ : nodeName_ : builtins.attrNames (lib.filterAttrs (unused_name_ : host_ : (
    builtins.elem nodeName_ (lib.attrByPath [ "intranetClaims" netName_ ] [] host_)
  )) hosts_);

  mkNode_ = netName_ : nodeName_ : derive_ : let

    claimantNames_ = claimantNamesOf_ netName_ nodeName_;

  in {

    claimed = (builtins.length enabledHostNames_) == 1
      && builtins.elem nodeName_ (lib.attrByPath
        [ "intranetClaims" netName_ ]
        []
        hosts_.${builtins.head enabledHostNames_}
      );

  } // (lib.optionalAttrs
    ((builtins.length claimantNames_) == 1)
    (derive_ hosts_.${builtins.head claimantNames_})
  );

in {

  imports = [
    ./os
  ];

  config = {

    modules.features.interconnect = {

      existModule = {
        os = true;
        hm = false;
      };

      intranets.ingress = {

        hub = {

          constraints.claimantCount = {
            min = 1;
            max = 1;
          };

        } // (mkNode_
          "ingress"
          "hub"
          (claimantHost_ : {
            ip = claimantHost_.publicIpAddress;
          })
        );

        spoke = (mkNode_
          "ingress"
          "spoke"
          (_ : {})
        );

      };

    };

    assertions = builtins.concatLists [

      [
        {
          assertion = !cfg.enable || (builtins.length enabledHostNames_) == 1;
          message = "`modules.features.interconnect.enable = true` requires exactly one host in `modules.hosts` to set `enable = true`.";
        }
      ]

      (builtins.concatLists
        (lib.mapAttrsToList
          (hostName_ : host_ : (builtins.concatLists
            (lib.mapAttrsToList
              (netName_ : nodeNames_ : builtins.concatLists [
                [
                  {
                    assertion = !cfg.enable || builtins.hasAttr netName_ cfg.intranets;
                    message = "Host `${hostName_}` claims the unknown `${netName_}` intranet.";
                  }
                ]
                (lib.optionals
                  (builtins.hasAttr netName_ cfg.intranets)
                  (builtins.map
                    (nodeName_ : {
                      assertion = !cfg.enable || builtins.hasAttr nodeName_ cfg.intranets.${netName_};
                      message = "Host `${hostName_}` claims the unknown `${netName_}.${nodeName_}` node.";
                    })
                    nodeNames_
                  )
                )
              ])
              host_.intranetClaims
            ))
          )
          hosts_
        )
      )

      (builtins.concatLists
        (lib.mapAttrsToList
          (netName_ : net_ : builtins.concatLists
            (lib.mapAttrsToList
              (nodeName_ : node_ : let
                claimantCount_ = builtins.length (claimantNamesOf_ netName_ nodeName_);
                constraints_ = node_.constraints.claimantCount;
              in [
                  {
                    assertion = constraints_.min == 0 || constraints_.max == 0 || constraints_.min <= constraints_.max;
                    message = "The minimum claimant count of `${netName_}.${nodeName_}` cannot exceed its maximum claimant count.";
                  }
                  {
                    assertion = !cfg.enable || (
                      (constraints_.min == 0 || claimantCount_ >= constraints_.min)
                      && (constraints_.max == 0 || claimantCount_ <= constraints_.max)
                    );
                    message = "The `${netName_}.${nodeName_}` node has ${builtins.toString claimantCount_} claimant(s), outside its configured range; zero means no limit (min: ${builtins.toString constraints_.min}, max: ${builtins.toString constraints_.max}).";
                  }
                ]
              )
              net_
            )
          )
          cfg.intranets
        )
      )

      [
        {
          assertion = (!cfg.enable) || ((builtins.length (claimantNamesOf_ "ingress" "hub")) != 1) || (cfg.intranets.ingress.hub.ip != null);
          message = "The host claiming the ingress `hub` node must provide `publicIpAddress`.";
        }
      ]

    ];

  };

}
