{ config, lib, pkgs, osConfig, niri-flake, ... } : {

  config = lib.mkIf config.programs.niri.enable {

    programs.niri.settings = {
      environment = osConfig.environment.sessionVariables;
      spawn-at-startup = [
        # { argv = [ "waybar" ]; }
      ];
      prefer-no-csd = false;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
    };

  };

}
