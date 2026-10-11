{ lib, llib, ... }: {
  options.moduleInternals.features.niri = {
    monitors = lib.mkOption {
      type = llib.types.monitors;
      internal = true;
      readOnly = true;
      description = "Monitor declarations used by Niri.";
    };

  };
}
