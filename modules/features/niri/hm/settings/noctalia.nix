{ config, lib, ... } : let

  noctaliaNiriSettingsEnable = (builtins.all
    (x_ : x_)
    [
      config.programs.niri.enable
      config.programs.noctalia.enable
    ]
  );

  noctaliaCommand = [ (lib.getExe config.programs.noctalia.package) ];

in {

  config = lib.mkIf noctaliaNiriSettingsEnable {
    programs.niri.settings = {

      spawn-at-startup = lib.mkAfter [
        {
          argv = noctaliaCommand;
        }
      ];

      binds = {

        "Mod+D" = lib.mkForce {
          hotkey-overlay = { title = "Run an Application: Noctalia Launcher"; };
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "panel-toggle" "launcher" ]
          ];
        };
        "Mod+C" = lib.mkForce {
          hotkey-overlay = { title = "Open Noctalia Control Center"; };
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "panel-toggle" "control-center" ]
          ];
        };
        "Mod+S" = lib.mkForce {
          hotkey-overlay = { title = "Open Noctalia Settings"; };
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "settings-toggle" ]
          ];
        };
        "Mod+N" = lib.mkForce {
          hotkey-overlay = { title = "Open Noctalia Notification History"; };
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "panel-toggle" "control-center" "notifications" ]
          ];
        };

        "XF86AudioRaiseVolume" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "volume-up" ]
          ];
        };
        "XF86AudioLowerVolume" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "volume-down" ]
          ];
        };
        "XF86AudioMute" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "volume-mute" ]
          ];
        };
        "XF86MonBrightnessUp" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "brightness-up" ]
          ];
        };
        "XF86MonBrightnessDown" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaCommand
            [ "msg" "brightness-down" ]
          ];
        };

      };
    };

  };

}
