{ lib, ... }: {
  options = {
    nixosConfigurations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, ... }: {
            options = {
              users = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule {
                    config = {
                      features.niri.module.features.niri.monitors = config.host.monitors;
                    };
                  }
                );
              };
            };
          }
        )
      );
    };
  };

  config = {
    nixosBuilderArgs.featureRegistry = {
      os.niri = ./os;
      hm.niri = ./hm;
    };
  };
}
