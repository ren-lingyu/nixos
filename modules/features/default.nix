{
  config,
  lib,
  llib,
  ...
}:
let

  enabledUserUids_ = builtins.map (user_: user_.uid) (
    builtins.attrValues (
      lib.filterAttrs (
        unused_userName_: user_:
        (builtins.all (x_: x_) [
          user_.enable
          (user_.uid != null)
        ])
      ) config.modules.users
    )
  );

in
{

  config = {

    assertions = builtins.concatLists (
      lib.mapAttrsToList (
        featureName_: feature_:
        (builtins.concatLists [
          (llib.modules.assertions.existModule {
            enable = feature_.enable;
            value = feature_.existModule;
            optionPath = "modules.features.${featureName_}.existModule";
            osModulePath = ./. + "/${featureName_}/os/default.nix";
            hmModulePath = ./. + "/${featureName_}/hm/default.nix";
            enabledMessage = "`modules.features.${featureName_}.enable = true` requires the feature module to be imported and declare `existModule.os` and `existModule.hm`.";
          })
          (lib.optionals
            (builtins.all (x_: x_) [
              feature_.enable
              (feature_.existModule.hm == true)
            ])
            [
              {
                assertion =
                  (builtins.length feature_.allowUidList) == (builtins.length (lib.unique feature_.allowUidList));
                message = "`modules.features.${featureName_}.allowUidList` must not contain duplicate UIDs.";
              }
              {
                assertion = builtins.all (uid_: builtins.elem uid_ enabledUserUids_) feature_.allowUidList;
                message = "`modules.features.${featureName_}.allowUidList` must only contain UIDs assigned to enabled users in `modules.users`.";
              }
            ]
          )
        ])
      ) config.modules.features
    );

  };

}
