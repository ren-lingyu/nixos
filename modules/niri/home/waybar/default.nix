{ config, lib, pkgs, osConfig, niri-flake, ... } : {

  imports = [
    ./settings.nix
  ];

  config = lib.mkIf config.programs.niri.enable {
    programs.waybar = {
        enable = true;
        package = pkgs.waybar;
        systemd = {
          enable = true;
          targets = [ config.wayland.systemd.target ];
          enableDebug = false;
          enableInspect = false;
        };
        style = builtins.readFile ./style.css;
      };
  };

}
