{
  options,
  config,
  pkgs,
  lib,
  llib,
  ...
}:
let

  mif = llib.hosts;

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

in
{
  config = lib.mkMerge [
    (lib.mkIf (enabledHost_.identity.keys.ssh.private.key != null) {
      age.secrets.ssh-identity = {
        rekeyFile = enabledHost_.identity.keys.ssh.private.key;
        intermediary = true;
      };
    })

    (lib.mkIf enabledHost_.identity.rootAccess {
      environment.systemPackages = with pkgs; [ yubikey-manager ];

      services.pcscd = {
        enable = lib.mkDefault true;
      };
    })
  ];
}
