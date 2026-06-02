{ config, lib, pkgs, osConfig, ... } : {

  imports = [
    ./settings.nix
  ];

  config = lib.mkIf (osConfig.modules.niri.enable && osConfig.modules.niri.waybar.enable) {
    programs.waybar = {
        enable = osConfig.modules.niri.waybar.enable;
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
