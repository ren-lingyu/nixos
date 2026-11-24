{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.features.niri;

  sessionWrapper =
    let
      commandName_ = "Niri";
    in
    pkgs.runCommand "niri-session-wrapper" { meta.mainProgram = "${commandName_}"; } (
      builtins.concatStringsSep "\n" [
        "mkdir -p $out/bin"
        "printf '%s\\n' ${
          lib.escapeShellArgs [
            "#!${lib.getExe pkgs.bash}"
            "export SYSTEMD_LOG_LEVEL=err"
            "exec ${lib.getExe' config.programs.niri.package "niri-session"}"
          ]
        } > $out/bin/${commandName_}"
        "chmod +x $out/bin/${commandName_}"
      ]
    );

in
{
  options.features.niri = {
    enable = lib.mkEnableOption "Niri system integration";
    noctalia.enable = lib.mkEnableOption "Noctalia system integration";
    sessionPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = sessionWrapper;
      description = "Executable session wrapper for login managers.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !cfg.noctalia.enable
          || (
            config.networking.networkmanager.enable
            && config.hardware.bluetooth.enable
            && (config.services.power-profiles-daemon.enable || config.services.tuned.enable)
            && config.services.upower.enable
          );
        message = "Noctalia requires NetworkManager, Bluetooth, a power profile service and UPower.";
      }
    ];

    programs.niri = {
      enable = cfg.enable;
      package = pkgs.niri;
    };

    programs.noctalia = lib.mkIf cfg.noctalia.enable {
      enable = true;
      package = pkgs.noctalia;
      recommendedServices.enable = true;
      systemd.enable = false;
    };

    environment.systemPackages = with pkgs; [ xwayland-satellite ];

    services.desktopManager.gnome.enable = lib.mkForce false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;
  };
}
