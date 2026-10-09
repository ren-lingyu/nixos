{
  config,
  pkgs,
  lib,
  llib,
  ...
}:
let

  cfg = config.modules.features.greeter;

  enabledHost_ = llib.moduleFunctions.hosts.default.getUniqueEnabledHost config.modules.hosts;

in
{

  imports = [ ./os ];

  config = {

    modules.features.greeter = {

      existModule = {
        os = true;
        hm = false;
      };

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
        assertion =
          let
            defaultMonitors_ = (
              builtins.attrValues (
                lib.filterAttrs (unused_name_: monitor_: (monitor_.role == "default")) enabledHost_.monitors
              )
            );
          in
          (builtins.any (x_: x_) [
            (!cfg.enable)
            ((builtins.length defaultMonitors_) == 1)
          ]);
        message = "`modules.features.greeter.enable = true` requires exactly one monitor in the enabled host's `monitors` to set `role = \"default\"`.";
      }
      {
        assertion = (
          builtins.any (x_: x_) [
            (!cfg.enable)
            (cfg.sessionPackages != [ ])
          ]
        );
        message = "`modules.features.greeter.enable = true` requires at least one session provider.";
      }
    ];

  };

}
