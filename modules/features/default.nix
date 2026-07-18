{ options, config, pkgs, lib, ... } : let

  featuresList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : ((type_ == "directory") && (builtins.pathExists (./. + "/${name_}/default.nix")))) (builtins.readDir ./.));

in {

  options = {

    modules.features = (builtins.listToAttrs (builtins.map (feature_ : {

      name = feature_;

      value = let

        possibleExtraOptionsPath_ = ./. + "/${builtins.toString feature_}/extra-options.nix";

      in {

        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to enable the ${feature_} feature.";
        };

        allowUidList = lib.mkOption {
          type = lib.types.listOf lib.types.ints.unsigned;
          default =
            if config.modules.features."${feature_}".existModule.hm
            then [ 1000 ]
            else [];
          example = [ 1000 1001 ];
          description = "User UIDs whose Home Manager configurations should import the ${feature_} module.";
        };

        existModule = {
          os = lib.mkOption {
            type = lib.types.unique {
              message = "Only one module may define `modules.features.${feature_}.existModule.os`.";
            } lib.types.bool;
            internal = true;
            default = false;
            example = true;
            description = "Whether this feature has an OS module.";
          };
          hm = lib.mkOption {
            type = lib.types.unique {
              message = "Only one module may define `modules.features.${feature_}.existModule.hm`.";
            } lib.types.bool;
            internal = true;
            default = false;
            example = true;
            description = "Whether this feature has a Home Manager module.";
          };
        };

      } // (lib.optionalAttrs (builtins.pathExists possibleExtraOptionsPath_) (
        (import possibleExtraOptionsPath_) feature_ {
          inherit options;
          inherit config;
          inherit pkgs;
          inherit lib;
        }
      ));

    }) featuresList_));

  };

  config = {

    assertions = builtins.concatLists (lib.mapAttrsToList (featureName_ : feature_ : (lib.optionals (feature_.enable && feature_.existModule.hm) [
      {
        assertion = (!feature_.enable) || (!feature_.existModule.hm) || (builtins.all (uid_ : let
          uidKey_ = builtins.toString uid_;
        in (
          (builtins.hasAttr uidKey_ config.modules.users) && (config.modules.users."${uidKey_}".enable) && (config.modules.users."${uidKey_}".home.manager.enable)
        )) feature_.allowUidList);
        message = "`modules.features.${featureName_}.allowUidList` must only contain UIDs declared in `modules.users`, and each listed user must have `enable = true` and `home.manager.enable = true`.";
      }
    ])) config.modules.features);

    home-manager.users = builtins.mapAttrs (uidKey_ : imports_ : {
      imports = imports_;
    }) (lib.foldlAttrs (x_ : featureName_ : feature_ : (builtins.foldl' (y_ : uid_ : (let
      homeManagerModulePath_ = ./. + "/${featureName_}/hm";
      uidString_ = builtins.toString uid_;
    in (
      if builtins.hasAttr uidString_ y_
      then y_ // { "${uidString_}" = [ homeManagerModulePath_ ] ++ y_."${uidString_}"; }
      else y_ // { "${uidString_}" = [ homeManagerModulePath_ ]; }
    ))) x_ (lib.optionals (feature_.enable && feature_.existModule.hm) feature_.allowUidList))) {} config.modules.features);

  };

}
