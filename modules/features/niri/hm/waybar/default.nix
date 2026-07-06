{ config, lib, pkgs, osConfig, ... } : let

  cfg = osConfig.modules.features.niri;

in {

  imports = [
    ./settings.nix
  ];

  config = lib.mkIf (cfg.enable && cfg.waybar.enable) {
    programs.waybar = {
        enable = cfg.waybar.enable;
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
