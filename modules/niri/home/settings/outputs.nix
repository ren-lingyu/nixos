{ config, lib, pkgs, osConfig, ... } : {

  config = lib.mkIf config.programs.niri.enable {
    
    programs.niri.settings.outputs = {
      "eDP-1" = {
        enable = true;
        focus-at-startup = true;
        mode = {
          width = 3072;
          height = 1920;
          refresh = 60.0;
        };
        scale = 1.75;
        transform = {
          rotation = 0;
          flipped = false;
        };
        position = {
          x = 0;
          y = 0;
        };
      };
      "HDMI-A-1" = {
        enable = true;
        focus-at-startup = false;
        scale = 1.0;
        transform = {
          rotation = 0;
          flipped = false;
        };
      };
    };
    
  };

}
