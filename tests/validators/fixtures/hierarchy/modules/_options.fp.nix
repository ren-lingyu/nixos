{ lib, ... }: {
  configuration.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  metadata.number = lib.mkOption {
    type = lib.types.int;
    default = 1;
  };
}
