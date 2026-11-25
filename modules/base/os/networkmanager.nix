{ config, lib, ... }: {
  options.base.networkmanager.enable = lib.mkOption {
    type = lib.types.bool;
    internal = true;
    readOnly = true;
    description = "Whether to apply the Base NetworkManager configuration.";
  };

  config = lib.mkIf config.base.networkmanager.enable { networking.networkmanager.enable = true; };
}
