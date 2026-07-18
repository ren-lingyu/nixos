{ config, lib, pkgs, osConfig, ... } : {

  config = lib.mkIf config.programs.niri.enable {

    home.packages = with pkgs; [
      adwaita-icon-theme
    ];

    systemd.user.sessionVariables = (builtins.mapAttrs (x: y: (lib.mkForce y)) config.programs.niri.settings.environment);

    programs.niri.settings = {
      environment = {
        QT_QPA_PLATFORM = "wayland";
        GDK_BACKEND = "wayland";
      };
      spawn-at-startup = builtins.concatLists [
        # (lib.optionals config.programs.noctalia-shell.enable [
        #   {
        #     argv = [ "noctalia-shell" ];
        #   }
        # ])
      ];
      prefer-no-csd = true;
      screenshot-path = "~/Pictures/Screenshots/ScreenShot_%Y-%m-%d_%H%M%S.png";
      cursor = {
        theme = "Adwaita";
        size = 48;
        hide-when-typing = true;
        hide-after-inactive-ms = 1000;
      };
      overview = {
        backdrop-color = "#000000";
      };
      xwayland-satellite = {
        enable = true;
        path = "${lib.getExe pkgs.xwayland-satellite}";
      };
    };

  };

}
