{ lib, ... }: {
  configuration =
    {
      name,
      configuration,
      registry,
      ...
    }:
    let
      enabledUsers = lib.filterAttrs (
        _: user: user.enable && user.uid != null
      ) configuration.modules.users;
      uids = builtins.map (user: user.uid) (builtins.attrValues enabledUsers);
    in
    builtins.all (valid: valid) (
      lib.mapAttrsToList (
        featureName: feature:
        if !feature.enable || !registry.features.${featureName}.metadata.existModule.hm then
          true
        else
          assert lib.assertMsg (
            builtins.length feature.allowUidList == builtins.length (lib.unique feature.allowUidList)
          ) "Feature `${featureName}` in system `${name}` must not contain duplicate allowUidList entries.";
          lib.assertMsg (builtins.all (uid: builtins.elem uid uids)
            feature.allowUidList
          ) "Feature `${featureName}` in system `${name}` may only target UIDs assigned to enabled Users."
      ) configuration.modules.features
    );
}
