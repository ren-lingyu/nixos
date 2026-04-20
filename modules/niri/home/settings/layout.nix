{ config, lib, pkgs, osConfig, niri-flake, ... } : {

  config = lib.mkIf config.programs.niri.enable {

    programs.niri.settings.layout = {
      gaps = 16;
      focus-ring = {
        enable = true;
        width = 4;
      };
      border = {
        enable = false;
        width = 4;
      };
      shadow = {
        enable = false;
        softness = 30;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        inactive-color = "#0007";
      };
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      default-column-width = {
        proportion = 1.0;
      };
      tab-indicator = {
        enable = true;
        width = 4;
        gap = 5;
        position = "left";
        active = { color = "#7fc8ff"; };
        inactive = { color = "#505050"; };
        urgent = { color = "#9b0000"; };
      };
      center-focused-column = "never";
    };

  };

}
