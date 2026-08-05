{ options, config, pkgs, lib, llib, ... } : let

  featureList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : ((type_ == "directory") && (builtins.pathExists (./. + "/${name_}/default.nix")))) (builtins.readDir ./.));
  enabledUserUids_ = builtins.map
    (user_ : user_.uid)
    (builtins.attrValues (lib.filterAttrs (unused_userName_ : user_ : user_.enable && user_.uid != null) config.modules.users));

  lmf = llib.moduleFunctions.features.default;

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
            if config.modules.features."${feature_}".existModule.hm == true
            then enabledUserUids_
            else [];
          example = [ 1000 1001 ];
          description = "User UIDs whose Home Manager configurations should import the ${feature_} module.";
        };

        existModule = lib.mkOption {
          type = llib.types.existModule {
            optionPath = "modules.features.${feature_}.existModule";
          };
          internal = true;
          default = {};
          description = "Module availability declared by the ${feature_} feature.";
        };

      } // (lib.optionalAttrs (builtins.pathExists possibleExtraOptionsPath_) (
        (import possibleExtraOptionsPath_) feature_ {
          inherit options;
          inherit config;
          inherit pkgs;
          inherit lib;
          inherit llib;
        }
      ));

    }) featureList_));

  };

  config = {

    assertions = builtins.concatLists (lib.mapAttrsToList (featureName_ : feature_ : (builtins.concatLists [
      (llib.assertions.existModule {
        enable = feature_.enable;
        value = feature_.existModule;
        optionPath = "modules.features.${featureName_}.existModule";
        osModulePath = ./. + "/${featureName_}/os/default.nix";
        hmModulePath = ./. + "/${featureName_}/hm/default.nix";
        enabledMessage = "`modules.features.${featureName_}.enable = true` requires the feature module to be imported and declare `existModule.os` and `existModule.hm`.";
      })
      (lib.optionals (feature_.enable && (feature_.existModule.hm == true)) [
        {
          assertion = (builtins.length feature_.allowUidList) == (builtins.length (lib.unique feature_.allowUidList));
          message = "`modules.features.${featureName_}.allowUidList` must not contain duplicate UIDs.";
        }
        {
          assertion = builtins.all (uid_ : builtins.elem uid_ enabledUserUids_) feature_.allowUidList;
          message = "`modules.features.${featureName_}.allowUidList` must only contain UIDs assigned to enabled users in `modules.users`.";
        }
      ])
    ])) config.modules.features);

    # Unlike NixOS `imports`, HM user imports can be assembled after option merging.
    home-manager.users = builtins.mapAttrs (unused_uidKey_ : imports_ : {
      imports = imports_;
    }) (lmf.groupImportsByUid
      (unused_featureName_ : feature_ : (
        lib.optionals
          (feature_.enable && (feature_.existModule.hm == true))
          feature_.allowUidList
        )
      )
      (featureName_ : unused_feature_ : [
        (./. + "/${featureName_}/hm")
      ])
      config.modules.features
    );

  };

}
