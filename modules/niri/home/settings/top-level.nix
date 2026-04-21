{ config, lib, pkgs, osConfig, niri-flake, ... } : {

  config = lib.mkIf config.programs.niri.enable {

    home.packages = with pkgs; [
      adwaita-icon-theme
    ];

    programs.niri.settings = {
      spawn-at-startup = builtins.concatLists [
        # (lib.optionals config.services.mako.enable [
        #   { argv = [ "${lib.getExe config.services.mako.package}" ]; }
        # ])
      ];
      prefer-no-csd = false;
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
      cursor = {
        theme = "Adwaita";
        size = 48;
        hide-when-typing = true;
        hide-after-inactive-ms = 1000;
      };
    };

  };

}
