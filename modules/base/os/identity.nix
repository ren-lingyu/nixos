{
  host,
  accounts,
  llib,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf ((host.identity.keys.ssh.private.key or null) != null) {
      age.secrets.ssh-identity = {
        rekeyFile = host.identity.keys.ssh.private.key;
        intermediary = true;
      };
    })

    {
      age.secrets =
        lib.mapAttrs'
          (
            uid: account:
            lib.nameValuePair (llib.identity.userAgeSecretName uid) (
              {
                rekeyFile =
                  assert lib.assertMsg (builtins.isPath account.profile.identity.keys.age.private.key)
                    "User `${account.profile.name}` age identity must reference an encrypted file.";
                  account.profile.identity.keys.age.private.key;
                owner = account.username;
                group = "root";
                mode = "0400";
              }
              // lib.optionalAttrs (account.profile.identity.keys.age.private.path != null) {
                path = account.profile.identity.keys.age.private.path;
              }
            )
          )
          (
            lib.filterAttrs (
              _: account: (account.profile.identity.keys.age.private.key or null) != null
            ) accounts
          );
    }

    (lib.mkIf host.identity.rootAccess {
      environment.systemPackages = with pkgs; [ yubikey-manager ];

      services.pcscd = {
        enable = lib.mkDefault true;
      };
    })
  ];
}
