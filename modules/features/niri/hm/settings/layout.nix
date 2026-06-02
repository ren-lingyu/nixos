{ config, lib, pkgs, osConfig, ... } : {

  config = lib.mkIf config.programs.niri.enable {

    programs.niri.settings.layout = rec {
      gaps = 0;
      background-color = "#000000";
      focus-ring = {
        enable = false;
        width = 1;
      };
      border = {
        enable = false;
        width = 1;
        active = {
          color = "#000000";
        };
        inactive = {
          color = "#000000";
        };
        urgent = {
          color = "#000000";
        };
      };
      struts = {
        top = 0;
        bottom = 0;
        left = 0;
        right = 0;
      };
      shadow = {
        enable = false;
        draw-behind-window = false;
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
        corner-radius = 0.0;
        position = "left";
        active = { color = "#7fc8ff"; };
        inactive = { color = "#505050"; };
        urgent = { color = "#9b0000"; };
      };
      center-focused-column = "never";
      insert-hint = {
        enable = true;
        display = {
          color = "#A0A0A080";
        };
      };
    };

  };

}
