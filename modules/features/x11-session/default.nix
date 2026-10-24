{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.modules.features.x11-session;

  sessionWrapper =
    let
      commandName_ = "X11-Session";
    in
    pkgs.runCommand "x11-session-wrapper" { meta.mainProgram = commandName_; } (
      builtins.concatStringsSep "\n" [
        "mkdir -p $out/bin $out/libexec"
        "cat > $out/libexec/x11-session-client <<'EOF'"
        "#!${lib.getExe pkgs.bash}"
        "export SYSTEMD_LOG_LEVEL=err"
        "export XDG_SESSION_TYPE=x11"
        "export XDG_SESSION_DESKTOP=icewm"
        "export XDG_CURRENT_DESKTOP=icewm"
        "export DESKTOP_SESSION=icewm"
        "exec ${lib.getExe' pkgs.dbus "dbus-run-session"} -- ${lib.getExe' pkgs.icewm "icewm-session"}"
        "EOF"
        "chmod +x $out/libexec/x11-session-client"
        "cat > $out/bin/${commandName_} <<EOF"
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
        "exec ${lib.getExe' pkgs.xinit "startx"} $out/libexec/x11-session-client -- -nolisten tcp"
        "EOF"
        "chmod +x $out/bin/${commandName_}"
      ]
    );

in
{
  config.moduleInternals.features.greeter.sessionPackages = lib.mkIf cfg.enable [ sessionWrapper ];
}
