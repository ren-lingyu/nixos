{ config, lib, pkgs, osConfig, niri-flake, ... } : {

  config = lib.mkIf config.programs.niri.enable {

    home.packages = with pkgs; [
      adwaita-icon-theme
    ];

    programs.niri.settings = {
      environment = {
        QT_QPA_PLATFORM = "wayland";
      };
      spawn-at-startup = builtins.concatLists [
        (lib.optionals config.programs.noctalia-shell.enable [
          {
            argv = [ "noctalia-shell" ];
          }
        ])
      ];
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d-%H-%M-%S.png";
      cursor = {
        theme = "Adwaita";
        size = 48;
        hide-when-typing = true;
        hide-after-inactive-ms = 1000;
      };
    };

  };

}
