{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.base.bluetooth.enable = lib.mkOption {
    type = lib.types.bool;
    internal = true;
    readOnly = true;
    description = "Whether to apply the Base Bluetooth configuration.";
  };

  config = lib.mkIf config.base.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez;
      powerOnBoot = true;
    };

    services.blueman.enable = true;
  };
}
