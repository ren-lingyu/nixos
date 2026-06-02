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

  options = {
    modules.niri = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
      noctalia-shell.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.modules.niri.enable;
        example = true;
      };
      waybar.enable = lib.mkOption {
        type = lib.types.bool;
        default = !config.modules.niri.noctalia-shell.enable && config.modules.niri.enable;
        example = false;
      };
      greeter = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = config.modules.niri.enable;
          example = true;
        };
      };
      monitor = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "eDP-1";
          example = "eDP-1";
        };
        width = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 3072;
          example = 3072;
        };
        height = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 1920;
          example = 1920;
        };
      };
    };
  };

  config = lib.mkMerge [

    {
      assertions = [
        {
          assertion = !config.modules.niri.greeter.enable || config.modules.niri.enable;
          message = "`modules.niri.greeter.enable = true` is only allowed when `modules.niri.enable = true;`.";
        }
        {
          assertion = !config.modules.niri.waybar.enable || config.modules.niri.enable;
          message = "`modules.niri.waybar.enable = true` is only allowed when `modules.niri.enable = true;`.";
        }
        {
          assertion = !config.modules.niri.noctalia-shell.enable || config.modules.niri.enable;
          message = "`modules.niri.noctalia-shell.enable = true` is only allowed when `modules.niri.enable = true;`.";
        }
        {
          assertion = !config.modules.niri.noctalia-shell.enable || noctaliaEnable;
          message = "Noctalia-Shell is depending on some system-level functionalities like bluetooth and power manager.";
        }
        {
          assertion = !(config.modules.niri.waybar.enable && config.modules.niri.noctalia-shell.enable);
          message = "`modules.niri.waybar.enable` and `modules.niri.noctalia-shell.enable` cannot be true simultaneously.";
        }
      ];
    }
    
    (lib.mkIf config.modules.niri.enable {    
      home-manager.users = {
        "${builtins.toString config.modules.user.uid}" = {
          imports = [
            ./hm
          ];
        };
      };
    })
    
  ];
  
}
