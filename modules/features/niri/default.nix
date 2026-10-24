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
        assertion = (
          builtins.any (x_: x_) [
            (!cfg.noctalia.enable)
            noctaliaEnable
          ]
        );
        message = "`modules.features.niri.noctalia.enable = true` requires system-level features (NetworkManager, Bluetooth, power-profiles-daemon/tuned, UPower) to be enabled.";
      }
    ];
  };
}
