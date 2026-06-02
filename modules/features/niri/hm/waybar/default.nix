{ config, lib, pkgs, osConfig, ... } : {

  imports = [
    ./settings.nix
  ];

  config = lib.mkIf (osConfig.modules.features.niri.enable && osConfig.modules.features.niri.waybar.enable) {
    programs.waybar = {
        enable = osConfig.modules.features.niri.waybar.enable;
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
