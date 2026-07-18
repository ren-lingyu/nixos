{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.niri;

  noctaliaEnable = (
    config.networking.networkmanager.enable
    &&
    config.hardware.bluetooth.enable
    && (
      config.services.power-profiles-daemon.enable
      ||
      config.services.tuned.enable
    ) &&
    config.services.upower.enable
  );

in {

  imports = [
    ./os
  ];

  config = {

    modules.features.niri = {

      existModule = {
        os = true;
        hm = true;
      };

      monitors = let
        enabledHosts_ = builtins.attrValues (lib.filterAttrs (unused_name_ : host_ : (
          host_.enable
        )) config.modules.hosts);
      in (
        if (builtins.length enabledHosts_) == 1
        then (builtins.head enabledHosts_).monitors
        else {}
      );

      session-wrapper = lib.mkIf config.programs.niri.enable (let
        commandName_ = "Niri";
      in pkgs.runCommand "niri-session-wrapper" {
        meta.mainProgram = "${commandName_}";
      } (builtins.concatStringsSep "\n" [
        "mkdir -p $out/bin"
        "cat > $out/bin/${commandName_} <<'EOF'"
        "#!${lib.getExe pkgs.bash}"
        "export SYSTEMD_LOG_LEVEL=err"
        "exec ${lib.getExe' config.programs.niri.package "niri-session"}"
        "EOF"
        "chmod +x $out/bin/${commandName_}"
      ]));

    };

    assertions = [
      {
        assertion = let
          enabledHosts_ = builtins.attrValues (lib.filterAttrs (unused_name_ : host_ : (
            host_.enable
          )) config.modules.hosts);
        in (!cfg.enable || (builtins.length enabledHosts_) == 1);
        message = "`modules.features.niri.enable = true` requires exactly one host in `modules.hosts` to set `enable = true`.";
      }
      {
        assertion = let
          defaultMonitors_ = builtins.attrValues (lib.filterAttrs (unused_name_ : monitor_ : (
            monitor_.role == "default"
          )) cfg.monitors);
        in (!cfg.enable || (builtins.length defaultMonitors_) == 1);
        message = "`modules.features.niri.enable = true` requires exactly one monitor in the enabled host's `monitors` to set `role = \"default\"`.";
      }
      {
        assertion = !cfg.waybar.enable || cfg.enable;
        message = "`modules.features.niri.waybar.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = !cfg.noctalia.enable || cfg.enable;
        message = "`modules.features.niri.noctalia.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = !cfg.noctalia.enable || noctaliaEnable;
        message = "`modules.features.niri.noctalia.enable = true` requires system-level features (NetworkManager, Bluetooth, power-profiles-daemon/tuned, UPower) to be enabled.";
      }
      {
        assertion = !(cfg.waybar.enable && cfg.noctalia.enable);
        message = "`modules.features.niri.waybar.enable` and `modules.features.niri.noctalia.enable` cannot be true simultaneously.";
      }
      {
        assertion = let
          wrapper_ = cfg.session-wrapper;
        in (
          if cfg.enable
          then (builtins.all (condition_ : condition_) [
            (wrapper_ ? meta)
            (wrapper_.meta ? mainProgram)
            (wrapper_.meta.mainProgram != "")
          ])
          else wrapper_ == null
        );
        message = builtins.concatStringsSep "\n" [
          "`modules.features.niri.session-wrapper` has an invalid state."
          "Expected:"
          "- when `modules.features.niri.enable = true`, `session-wrapper` must be a non-null package with a non-empty `meta.mainProgram`."
          "- when `modules.features.niri.enable = false`, `session-wrapper` must be null."
        ];
      }
    ];

  };

}
