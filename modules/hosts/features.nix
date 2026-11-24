{ lib, ... }: {
  options.nixosConfigurations = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }: {
          config.features.greeter.module.features.greeter.monitorName =
            let
              defaults = lib.filter (monitor: monitor.role == "default") (lib.attrValues config.host.monitors);
            in
            assert lib.assertMsg (
              builtins.length defaults == 1
            ) "Greeter requires exactly one default monitor in Host `${config.host.name}`.";
            (builtins.head defaults).name;

          options.users = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule { config.features.niri.module.features.niri.monitors = config.host.monitors; }
            );
          };
        }
      )
    );
  };
}
