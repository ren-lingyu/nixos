{ config, lib, pkgs, osConfig, ... } : let

  cfg = osConfig.modules.features.niri;

in {

  config = lib.mkIf config.programs.niri.enable {

    programs.niri.settings.input = {
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
      warp-mouse-to-focus.enable = true;
      keyboard = {
        xkb = {
          layout = "us,de";
          options = "grp:win_space_toggle";
        };
        numlock = true;
      };
      touchpad = {
        enable = true;
        tap = true;
        natural-scroll = true;
        scroll-method = "two-finger";
      };
      mouse = {
        enable = true;
        natural-scroll = true;
        accel-profile = "flat";
      };
      tablet = {
        enable = true;
        map-to-output = (builtins.head (builtins.attrValues (lib.filterAttrs
          (_ : monitor_ : monitor_.role == "default")
          cfg.monitors
        ))).name;
      };
    };

  };

}
