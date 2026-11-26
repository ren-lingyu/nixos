{
  config,
  accounts,
  lib,
  llib,
  ...
}:
{
  config.age.secrets = builtins.listToAttrs (
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
        ) (llib.secrets.flattenTree config.home-manager.users.${uid}.secrets)
      ) accounts
    )
  );
}
