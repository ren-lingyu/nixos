{ lib, ... }: {
  configuration =
    {
      name,
      configuration,
      registry,
      ...
    }:
    let
      users = configuration.modules.users;
      enabled = lib.filterAttrs (_: user: user.enable) users;
      uids = builtins.map (user: user.uid) (builtins.attrValues enabled);
      usernames = builtins.map (user: user.username) (builtins.attrValues enabled);
      hosts = builtins.attrNames (lib.filterAttrs (_: host: host.enable) configuration.modules.hosts);
    in
    assert lib.assertMsg (builtins.all (
      uid: uid != null
    ) uids) "Enabled Users in system `${name}` must have UIDs assigned by final composition.";
    assert lib.assertMsg (
      builtins.length uids == builtins.length (lib.unique uids)
    ) "Enabled Users in system `${name}` must have unique UIDs.";
    assert lib.assertMsg (
      builtins.length usernames == builtins.length (lib.unique usernames)
    ) "Enabled Users in system `${name}` must have unique login names.";
    assert lib.assertMsg (builtins.all (user: user.uid == null || user.uid >= 1000) (
      builtins.attrValues users
    )) "Every assigned User UID in system `${name}` must be at least 1000, including disabled Users.";
    assert lib.assertMsg (builtins.all (user: lib.hasPrefix "/" user.homeDirectory) (
      builtins.attrValues enabled
    )) "Enabled Users in system `${name}` must have absolute home directories.";
    if builtins.length hosts != 1 then
      true
    else
      let
        hostName = builtins.head hosts;
        registered = builtins.attrValues registry.hosts.${hostName}.metadata.users;
      in
      lib.assertMsg (builtins.all (uid: builtins.elem uid registered)
        uids
      ) "Every enabled User in system `${name}` must be registered in Host `${hostName}` UID metadata.";
}
