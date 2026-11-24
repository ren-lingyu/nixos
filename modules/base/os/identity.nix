{
  options,
  config,
  host,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf (host.identity.keys.ssh.private.key != null) {
      age.secrets.ssh-identity = {
        rekeyFile = host.identity.keys.ssh.private.key;
        intermediary = true;
      };
    })

    (lib.mkIf host.identity.rootAccess {
      environment.systemPackages = with pkgs; [ yubikey-manager ];

      services.pcscd = {
        enable = lib.mkDefault true;
      };
    })
  ];
}
