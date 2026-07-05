{ config, pkgs, lib, ... } : {
  
  imports = [
    ./os
  ];
  
  config = {
    
    modules.features.x11-session = {
      
      existModule = {
        os = true;
        hm = true;
      };
      
      session-wrapper = lib.mkIf config.modules.features.x11-session.enable (let
        commandName_ = "X11-Session";
      in (pkgs.runCommand "x11-session-wrapper" {
        meta.mainProgram = commandName_;
      } (builtins.concatStringsSep "\n" [
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
      ])));
      
    };
    
    assertions = [
      {
        assertion = (
          if config.modules.features.x11-session.enable
          then
            if config.modules.features.x11-session.session-wrapper == null
            then false
            else builtins.all (condition_ : condition_) [
              (config.modules.features.x11-session.session-wrapper ? meta)
              (config.modules.features.x11-session.session-wrapper.meta ? mainProgram)
              (config.modules.features.x11-session.session-wrapper.meta.mainProgram != "")
            ]
          else config.modules.features.x11-session.session-wrapper == null
        );
        
        message = builtins.concatStringsSep "\n" [
          "`modules.features.x11-session.session-wrapper` has an invalid state."
          "Expected:"
          "- when `modules.features.x11-session.enable = true`, `session-wrapper` must be a non-null package with a non-empty `meta.mainProgram`."
          "- when `modules.features.x11-session.enable = false`, `session-wrapper` must be null."
        ];
      }
    ];
    
  };
  
}
