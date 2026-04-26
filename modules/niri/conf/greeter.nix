{ config, lib, pkgs, ... } : let

  sddmThemePackages = with pkgs; [
    (sddm-astronaut.override {
      themeConfig = {
        # ScreenWidth = "3072";
        # ScreenHeight = "1920";
        FontSize = "24";
      };
    })
  ];

in {

  config = lib.mkIf config.programs.niri.enable {

    environment.systemPackages = builtins.concatLists [
      sddmThemePackages
      (with pkgs; [
        cage
      ])
    ];
    
    services.displayManager = {
      enable = true;
      defaultSession = null;
      autoLogin.enable = false;
      gdm = {
        enable = false;
      };
      sddm = {
        enable = true;
        enableHidpi = true;
        package = pkgs.kdePackages.sddm;
        wayland = {
          enable = true;
          compositor = "weston";
        };
        settings = {
          Theme = {
            CursorTheme = "Adwaita";
            CursorSize = "48";
          };
          Wayland = {
            CompositorCommand = "${config.services.displayManager.sddm.wayland.compositor} --output=eDP-1:3072x1920";
            SessionDir = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
          };
        };
        autoNumlock = false;
        extraPackages = builtins.concatLists [
          sddmThemePackages
          (with pkgs; [
            adwaita-icon-theme
          ])
        ];
        theme = "sddm-astronaut-theme";
        setupScript = "";
        stopScript = "";
      };
    };
    
  };

}
