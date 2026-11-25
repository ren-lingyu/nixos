{
  pkgs,
  lib,
  config,
  ...
}:
let
  sessionWrapper =
    let
      commandName_ = "X11-Session";
    in
    pkgs.runCommand "x11-session-wrapper" { meta.mainProgram = commandName_; } (
      builtins.concatStringsSep "\n" [
        "mkdir -p $out/bin $out/libexec"
        "printf '%s\\n' ${
          lib.escapeShellArgs [
            "#!${lib.getExe pkgs.bash}"
            "export SYSTEMD_LOG_LEVEL=err"
            "export XDG_SESSION_TYPE=x11"
            "export XDG_SESSION_DESKTOP=icewm"
            "export XDG_CURRENT_DESKTOP=icewm"
            "export DESKTOP_SESSION=icewm"
            "exec ${lib.getExe' pkgs.dbus "dbus-run-session"} -- ${lib.getExe' pkgs.icewm "icewm-session"}"
          ]
        } > $out/libexec/x11-session-client"
        "chmod +x $out/libexec/x11-session-client"
        "printf '%s\\n' ${
          lib.escapeShellArgs [
            "#!${lib.getExe pkgs.bash}"
            "export SYSTEMD_LOG_LEVEL=err"
            "export XDG_SESSION_TYPE=x11"
            "export XDG_SESSION_DESKTOP=icewm"
            "export XDG_CURRENT_DESKTOP=icewm"
            "export DESKTOP_SESSION=icewm"
            "unset DISPLAY"
            "unset WAYLAND_DISPLAY"
            "unset SWAYSOCK"
            "unset NIRI_SOCKET"
            "exec ${lib.getExe' pkgs.xinit "startx"} @output@/libexec/x11-session-client -- -nolisten tcp"
          ]
        } | sed \"s|@output@|$out|g\" > $out/bin/${commandName_}"
        "chmod +x $out/bin/${commandName_}"
      ]
    );
in
{
  options.features.x11-session = {
    enable = lib.mkEnableOption "system X11 session integration";
    sessionPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = sessionWrapper;
      description = "Executable session wrapper for login managers.";
    };
  };

  config = lib.mkIf config.features.x11-session.enable {
    services.xserver = {
      enable = true;

      displayManager = {
        startx.enable = true;
      };

      windowManager.icewm = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      xdg-utils
      xrandr
    ];
  };
}
