{
  config,
  pkgs,
  lib,
  llib,
  ...
}:
let

  cfg = config.modules.features.greeter;

  enabledHost_ = llib.hosts.getUniqueEnabledHost config.modules.hosts;

in
{

  config = {

    moduleInternals.features.greeter = {

      monitor =
        let
          defaultMonitors_ = (
            builtins.attrValues (
              lib.filterAttrs (unused_name_: monitor_: (monitor_.role == "default")) enabledHost_.monitors
            )
          );
        in
        {
          name =
            if (builtins.length defaultMonitors_) == 1 then (builtins.head defaultMonitors_).name else null;
        };

    };

    assertions = [
      {
        assertion = builtins.all (
          package: (package.meta.mainProgram or "") != ""
        ) config.moduleInternals.features.greeter.sessionPackages;
        message = "Every package in `moduleInternals.features.greeter.sessionPackages` must declare a non-empty `meta.mainProgram`.";
      }
      {
        assertion = (
          builtins.any (x_: x_) [
            (!cfg.enable)
            (config.moduleInternals.features.greeter.sessionPackages != [ ])
          ]
        );
        message = "`modules.features.greeter.enable = true` requires at least one session provider.";
      }
    ];

  };

}
