{ config, lib, pkgs, osConfig, ... } : let

  noctaliaNiriSettingsEnable = config.programs.niri.enable && config.programs.noctalia-shell.enable;
  
  noctaliaShellCommand = [ "noctalia-shell" ];
  
in {

  config = lib.mkIf noctaliaNiriSettingsEnable {
    programs.niri.settings = {

      spawn-at-startup = lib.mkAfter [
        {
          argv = noctaliaShellCommand;
        }
      ];
      
      binds = {

        "Mod+D" = lib.mkForce {
          hotkey-overlay = { title = "Run an Application: Noctalia appLauncher"; };
          action.spawn = builtins.concatLists [
            noctaliaShellCommand
            [ "ipc" "call" "launcher" "toggle" ]
          ];
        };
        "Mod+C" = lib.mkForce {
          hotkey-overlay = { title = "Open Noctalia Control Center"; };
          action.spawn = builtins.concatLists [
            noctaliaShellCommand
            [ "ipc" "call" "controlCenter" "toggle" ]
          ];
        };
        "Mod+S" = lib.mkForce {
          hotkey-overlay = { title = "Open Noctalia Settings"; };
          action.spawn = builtins.concatLists [
            noctaliaShellCommand
            [ "ipc" "call" "settings" "toggle"]
          ];
        };

        "XF86AudioRaiseVolume" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaShellCommand
            [ "ipc" "call" "volume" "increase" ]
          ];
        };
        "XF86AudioLowerVolume" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaShellCommand
            [ "ipc" "call" "volume" "decrease" ]
          ];
        };
        "XF86AudioMute" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaShellCommand
            [ "ipc" "call" "volume" "muteOutput" ]
          ];
        };
        "XF86MonBrightnessUp" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaShellCommand
            [ "ipc" "call" "brightness" "increase" ]
          ];
        };
        "XF86MonBrightnessDown" = lib.mkForce {
          action.spawn = builtins.concatLists [
            noctaliaShellCommand
            [ "ipc" "call" "brightness" "decrease" ]
          ];
        };
        
      };
    };

  };

}
