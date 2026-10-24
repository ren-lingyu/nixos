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
  config = lib.mkIf enabledHost_.identity.rootAccess {
    environment.systemPackages = with pkgs; [ yubikey-manager ];

    services.pcscd = {
      enable = lib.mkDefault true;
    };
  };
}
