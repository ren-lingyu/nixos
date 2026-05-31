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

  niriSessionWrapper = let 
    niriSessionWrapperCommandName = "Niri";
  in pkgs.runCommand "niri-session-wrapper" {
    meta.mainProgram = "${niriSessionWrapperCommandName}";
  } (
    builtins.concatStringsSep "\n" [
      "mkdir -p $out/bin"
      "cat > $out/bin/${niriSessionWrapperCommandName} <<'EOF'"
      "#!${lib.getExe pkgs.bash}"
      "export SYSTEMD_LOG_LEVEL=err"
      "exec ${lib.getExe' config.programs.niri.package "niri-session"}"
      "EOF"
      "chmod +x $out/bin/${niriSessionWrapperCommandName}"
    ]
  );

in {

  config = lib.mkIf config.programs.niri.enable {

    environment.systemPackages = builtins.concatLists [
      (lib.optionals config.services.displayManager.sddm.enable sddmThemePackages)
      (lib.optionals config.services.greetd.enable [ niriSessionWrapper ])
    ];
    
    services.displayManager = {
      enable = true;
      defaultSession = null;
      autoLogin.enable = false;
      gdm = {
        enable = false;
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

    programs.sway = {
      enable = true;
      package = pkgs.sway;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraOptions = [ ];
    };
    
    users = {
      groups.greeter = { };
      users.greeter = {
        name = "greeter";
        isSystemUser = true;
        group = "greeter";
        home = "/var/users/greeter";
        extraGroups = builtins.concatLists [
          [ "input" ]
          (lib.optionals config.services.seatd.enable [ config.services.seatd.group ])
        ];
        createHome = true;
      };
    };
    
    services.greetd = {
      enable = true;
      settings = {
        terminal = {
          vt = 1;
        };
        default_session = lib.mkForce (let
          concatWords = builtins.concatStringsSep (builtins.fromJSON ''"\u0020"'');
          concatLines = builtins.concatStringsSep "\n";
          greeterOutput = "eDP-1";
          swayGreetConfig = let
            swayGreetCommand = builtins.concatStringsSep ";" [
              (concatWords [
                "${lib.getExe' pkgs.coreutils "env"}"
                "GTK_THEME=Adwaita:dark"
                "${lib.getExe pkgs.gtkgreet}"
                "-l -c"
                "${builtins.baseNameOf (lib.getExe niriSessionWrapper)}"
              ])
              (concatWords [
                "${lib.getExe' config.programs.sway.package "swaymsg"} exit"
                ">/dev/null 2>&1 || true"
              ])
            ];
          in pkgs.writeText "greetd-sway-config" (concatLines [
            "output * bg #000000 solid_color"
            "focus output ${greeterOutput}"
            "focus_on_window_activation none"
            "default_border none"
            "default_floating_border none"
            "titlebar_border_thickness 0"
            "titlebar_padding 0"
            "exec \"${swayGreetCommand}\""
          ]);
          greetdCommand = concatWords [
            "${lib.getExe' pkgs.systemd "systemd-cat"}"
            "-t"
            "greetd-sway-gtkgreet"
            "--"
            "${lib.getExe' pkgs.dbus "dbus-run-session"}"
            "--"
            "${lib.getExe' pkgs.coreutils "env"}"
            "-u" "DISPLAY"
            "-u" "WAYLAND_DISPLAY"
            "-u" "SWAYSOCK"
            "GTK_USE_PORTAL=0"
            "GDK_DEBUG=no-portals"
            "LIBSEAT_BACKEND=logind"
            "WLR_BACKENDS=drm,libinput"
            "XDG_SESSION_TYPE=wayland"
            "${lib.getExe config.programs.sway.package}"
            "--config"
            "${swayGreetConfig}"
          ];
        in {
          user = "greeter";
          command = greetdCommand;
        });
      };
    };
    
  };

}
