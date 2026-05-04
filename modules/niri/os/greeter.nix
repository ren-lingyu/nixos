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
      (lib.optionals config.services.displayManager.sddm.enable sddmThemePackages)
      (with pkgs; [
        cage
      ])
    ];
    
    services.displayManager = {
      enable = true;
      defaultSession = null;
      autoLogin.enable = false;
      gdm = {
        enable = true;
        wayland = true;
        autoSuspend = true;
        banner = null;
        debug = false;
        settings = {
          daemon = {
            AutomaticLoginEnable = false;
            TimedLoginEnable = false;
            DefaultSession = "niri.desktop";
          };
          security = {
            AllowRoot = false;
            AutomaticLoginAllowRoot = false;
          };
          xdmcp = {
            Enable = false;
          };
        };
      };
      sddm = {
        enable = false;
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

    services.greetd = {
      enable = false;
      settings = {
        default_session = {
          command = builtins.concatStringsSep (builtins.fromJSON ''"\u0020"'') [
            "${lib.getExe pkgs.tuigreet}"
            "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
            "--time"
            "--time-format '%Y-%m-%d %H:%M:%S'"
            "--asterisks"
            "--remember"
            "--remember-session"
          ];
        };
      };
    };
    
  };

}
