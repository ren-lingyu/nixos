{
  config,
  pkgs,
  lib,
  llib,
  ...
}:
let

  cfg = config.modules.features.niri;

  enabledHost_ = llib.hosts.getUniqueEnabledHost config.modules.hosts;

  noctaliaEnable = (
    builtins.all (x_: x_) [
      config.networking.networkmanager.enable
      config.hardware.bluetooth.enable
      (builtins.any (x_: x_) [
        config.services.power-profiles-daemon.enable
        config.services.tuned.enable
      ])
      config.services.upower.enable
    ]
  );

  sessionWrapper =
    let
      commandName_ = "Niri";
    in
    pkgs.runCommand "niri-session-wrapper" { meta.mainProgram = "${commandName_}"; } (
      builtins.concatStringsSep "\n" [
        "mkdir -p $out/bin"
        "cat > $out/bin/${commandName_} <<'EOF'"
        "#!${lib.getExe pkgs.bash}"
        "export SYSTEMD_LOG_LEVEL=err"
        "exec ${lib.getExe' config.programs.niri.package "niri-session"}"
        "EOF"
        "chmod +x $out/bin/${commandName_}"
      ]
    );

in
{

  config = {

    moduleInternals.features.niri.monitors = enabledHost_.monitors;

    moduleInternals.features.greeter.sessionPackages = lib.mkIf cfg.enable (
      lib.mkBefore [ sessionWrapper ]
    );

    assertions = [
      {
        assertion =
          let
            defaultMonitors_ = (
              builtins.attrValues (
                lib.filterAttrs (
                  unused_name_: monitor_: (monitor_.role == "default")
                ) config.moduleInternals.features.niri.monitors
              )
            );
          in
          (builtins.any (x_: x_) [
            (!cfg.enable)
            ((builtins.length defaultMonitors_) == 1)
          ]);
        message = "`modules.features.niri.enable = true` requires exactly one monitor in the enabled host's `monitors` to set `role = \"default\"`.";
      }
      {
        assertion = (
          builtins.any (x_: x_) [
            (!cfg.waybar.enable)
            cfg.enable
          ]
        );
        message = "`modules.features.niri.waybar.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = (
          builtins.any (x_: x_) [
            (!cfg.noctalia.enable)
            cfg.enable
          ]
        );
        message = "`modules.features.niri.noctalia.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = (
          builtins.any (x_: x_) [
            (!cfg.noctalia.enable)
            noctaliaEnable
          ]
        );
        message = "`modules.features.niri.noctalia.enable = true` requires system-level features (NetworkManager, Bluetooth, power-profiles-daemon/tuned, UPower) to be enabled.";
      }
      {
        assertion =
          !(builtins.all (x_: x_) [
            cfg.waybar.enable
            cfg.noctalia.enable
          ]);
        message = "`modules.features.niri.waybar.enable` and `modules.features.niri.noctalia.enable` cannot be true simultaneously.";
      }
    ];

  };

}
