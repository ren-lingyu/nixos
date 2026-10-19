{ config, lib, ... }:
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
        lib.optionals
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
      ) config.modules.features
    );

  };

}
