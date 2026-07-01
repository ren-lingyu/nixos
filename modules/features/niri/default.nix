{ config, pkgs, lib, ... } : let

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
      
      monitors = config.modules.hosts.monitors;
      
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
        assertion = !config.modules.features.niri.waybar.enable || config.modules.features.niri.enable;
        message = "`modules.features.niri.waybar.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = !config.modules.features.niri.noctalia.enable || config.modules.features.niri.enable;
        message = "`modules.features.niri.noctalia.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = !config.modules.features.niri.noctalia.enable || noctaliaEnable;
        message = "`modules.features.niri.noctalia.enable = true` requires system-level features (NetworkManager, Bluetooth, power-profiles-daemon/tuned, UPower) to be enabled.";
      }
      {
        assertion = !(config.modules.features.niri.waybar.enable && config.modules.features.niri.noctalia.enable);
        message = "`modules.features.niri.waybar.enable` and `modules.features.niri.noctalia.enable` cannot be true simultaneously.";
      }
      {
        assertion = let
          wrapper_ = config.modules.features.niri.session-wrapper;
        in (
          if config.modules.features.niri.enable
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
