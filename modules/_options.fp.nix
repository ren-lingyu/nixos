{ lib, ... }: {
  configuration = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable this module.";
    };
  };

  metadata = { };
}
