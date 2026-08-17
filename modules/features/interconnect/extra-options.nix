feature_ : { options, config, pkgs, lib, llib, ... } : {

  intranets = lib.mkOption {

    type = lib.types.unique {
      message = "`modules.features.${feature_}.intranets` can only be defined once.";
    } (lib.types.submodule {
      options = (lib.mapAttrs
        (net_ : nodes_ : (builtins.listToAttrs
          (builtins.map
            (node_ : {
              name = node_;
              value = lib.mergeAttrsList [
                {
                  constraints.claimantCount = {
                    min = lib.mkOption {
                      type = lib.types.unique {
                        message = "`modules.features.${feature_}.intranets.${net_}.${node_}.constraints.claimantCount.min` can only be defined once.";
                      } lib.types.ints.unsigned;
                      default = 0;
                      description = "Minimum number of hosts allowed to claim this node; zero means no lower limit.";
                    };
                    max = lib.mkOption {
                      type = lib.types.unique {
                        message = "`modules.features.${feature_}.intranets.${net_}.${node_}.constraints.claimantCount.max` can only be defined once.";
                      } lib.types.ints.unsigned;
                      default = 0;
                      description = "Maximum number of hosts allowed to claim this node; zero means no upper limit.";
                    };
                  };
                  claimed = lib.mkOption {
                    type = lib.types.unique {
                      message = "`modules.features.${feature_}.intranets.${net_}.${node_}.claimed` can only be defined once.";
                    } lib.types.bool;
                    description = "Whether the enabled host claims the ${node_} node of the ${net_} intranet.";
                  };
                }
                (lib.optionalAttrs
                  ([ net_ node_ ] == [ "ingress" "hub" ])
                  {
                    publicIpAddress = lib.mkOption {
                      type = lib.types.unique {
                        message = "`modules.features.${feature_}.intranets.ingress.hub.publicIpAddress` can only be defined once.";
                      } (lib.types.nullOr lib.types.str);
                      default = null;
                      description = "Public IP address derived from the host claiming the ingress hub node.";
                    };
                  }
                )
              ];
            })
            nodes_
          )
        ))
        {
          ingress = [
            "hub"
            "spoke"
          ];
        }
      );
    });
    internal = true;
    description = "Interconnect intranets and their derived node state.";

  };

}
