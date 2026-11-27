{
  config,
  accounts,
  lib,
  llib,
  ...
}:
{
  config = {
    age.secrets = builtins.listToAttrs (
      lib.concatLists (
        lib.mapAttrsToList (
          uid: account:
          builtins.map (
            secret:
            lib.nameValuePair (llib.secrets.userSecretName uid secret.path) {
              inherit (secret) rekeyFile;
              owner = account.username;
              group = "root";
              mode = "0400";
            }
          ) (llib.secrets.flattenTree account.secrets)
        ) accounts
      )
    );

    home-manager.users = lib.mapAttrs (uid: account: {
      secrets = lib.foldl' lib.recursiveUpdate { } (
        builtins.map (
          secret:
          lib.setAttrByPath secret.path {
            inherit (config.age.secrets.${llib.secrets.userSecretName uid secret.path}) path;
          }
        ) (llib.secrets.flattenTree account.secrets)
      );
    }) accounts;
  };
}
