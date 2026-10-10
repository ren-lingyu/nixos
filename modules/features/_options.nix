{
  config,
  lib,
  path,
  ...
}:
let
  feature_ = lib.last path;
  enabledUserUids_ = builtins.map (user_: user_.uid) (
    builtins.attrValues (
      lib.filterAttrs (
        unused_userName_: user_:
        builtins.all (condition: condition) [
          user_.enable
          (user_.uid != null)
        ]
      ) config.modules.users
    )
  );
in
{
  allowUidList = lib.mkOption {
    type = lib.types.listOf lib.types.ints.unsigned;
    default =
      if config.modules.features.${feature_}.existModule.hm == true then enabledUserUids_ else [ ];
    example = [
      1000
      1001
    ];
    description = "User UIDs whose Home Manager configurations should import the ${feature_} module.";
  };
}
