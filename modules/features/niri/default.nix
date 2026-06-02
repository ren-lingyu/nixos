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
    modules.features.niri = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
      noctalia-shell.enable = lib.mkOption {
        type = lib.types.bool;
        default = config.modules.features.niri.enable;
        example = true;
      };
      waybar.enable = lib.mkOption {
        type = lib.types.bool;
        default = !config.modules.features.niri.noctalia-shell.enable && config.modules.features.niri.enable;
        example = false;
      };
      greeter = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = config.modules.features.niri.enable;
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
          assertion = !config.modules.features.niri.greeter.enable || config.modules.features.niri.enable;
          message = "`modules.features.niri.greeter.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
        }
        {
          assertion = !config.modules.features.niri.waybar.enable || config.modules.features.niri.enable;
          message = "`modules.features.niri.waybar.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
        }
        {
          assertion = !config.modules.features.niri.noctalia-shell.enable || config.modules.features.niri.enable;
          message = "`modules.features.niri.noctalia-shell.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
        }
        {
          assertion = !config.modules.features.niri.noctalia-shell.enable || noctaliaEnable;
          message = "Noctalia-Shell is depending on some system-level functionalities like bluetooth and power manager.";
        }
        {
          assertion = !(config.modules.features.niri.waybar.enable && config.modules.features.niri.noctalia-shell.enable);
          message = "`modules.features.niri.waybar.enable` and `modules.features.niri.noctalia-shell.enable` cannot be true simultaneously.";
        }
      ];
    }
    
    (lib.mkIf config.modules.features.niri.enable {    
      home-manager.users = {
        "${builtins.toString config.modules.users.uid}" = {
          imports = [
            ./hm
          ];
        };
      };
    })
    
  ];
  
}
