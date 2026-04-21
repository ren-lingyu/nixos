{ config, lib, pkgs, osConfig, niri-flake, noctalia-shell, ... } : let

  waybarEnable = (config.programs.niri.enable && !config.programs.noctalia-shell.enable);

in {

  imports = [
    ./settings.nix
  ];

  config = lib.mkIf waybarEnable {
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
