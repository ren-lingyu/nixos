feature_ : { options, config, pkgs, lib, llib, ... } : let

  cfg = config.modules.features.${feature_};

in {

  intranetDefs = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        number = lib.mkOption {
          type = lib.types.ints.between 0 255;
          description = "Stable number assigned to this intranet.";
        };
        nodes = lib.mkOption {
          type = lib.types.listOf lib.types.nonEmptyStr;
          description = "Node names declared by this intranet.";
        };
      };
    });
    internal = true;
    readOnly = true;
    default = {
      ingress = {
        number = 0;
        nodes = [
          "hub"
          "spoke"
        ];
      };
    };
    description = "Internal definitions of interconnect intranets.";
  };

  intranets = lib.mkOption {

    type = lib.types.submodule {
      options = (lib.mapAttrs
        (net_ : netDef_ : (builtins.listToAttrs
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
                  intraIpAddress = lib.mkOption {
                    type = lib.types.unique {
                      message = "`modules.features.${feature_}.intranets.${net_}.${node_}.intraIpAddress` can only be defined once.";
                    } (lib.types.nullOr lib.types.str);
                    default = null;
                    example = "10.100.0.1";
                    description = "Internal IP address derived from the host claiming the ${net_} ${node_} node.";
                  };
                }
                (lib.optionalAttrs
                  ([ net_ node_ ] == [ "ingress" "hub" ])
                  {
                    publicIpAddress = lib.mkOption {
                      type = lib.types.unique {
                        message = "`modules.features.${feature_}.intranets.${net_}.${node_}.publicIpAddress` can only be defined once.";
                      } (lib.types.nullOr lib.types.str);
                      default = null;
                      description = "Public IP address derived from the host claiming the ${net_} ${node_} node.";
                    };
                    principalUid = lib.mkOption {
                      type = lib.types.unique {
                        message = "`modules.features.${feature_}.intranets.${net_}.${node_}.principalUid` can only be defined once.";
                      } lib.types.ints.u32;
                      description = "UID of the local principal for the ${net_} ${node_} node.";
                    };
                  }
                )
              ];
            })
            netDef_.nodes
          )
        ))
        cfg.intranetDefs
      );
    };
    internal = true;
    readOnly = true;
    description = "Interconnect intranets and their derived node state.";

  };

}
