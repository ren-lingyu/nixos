{ config, lib, pkgs, ... } : let
  
  cfg = config.modules.features.greeter;
  
in {
  
  config = lib.mkIf cfg.enable {
    
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
    
    environment = {
      systemPackages = cfg.sessionPackages;
      etc = {
        "greetd/environments" = {
          enable = true;
          target = "greetd/environments";
          text = (builtins.concatStringsSep "\n" (builtins.map (
            x_ : "${builtins.baseNameOf (lib.getExe x_)}"
          ) cfg.sessionPackages)) + "\n";
        };
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
    
    services.greetd = {
      enable = cfg.enable;
      settings = {
        terminal = {
          vt = 1;
        };
        default_session = lib.mkForce (let
          concatWords_ = builtins.concatStringsSep (builtins.fromJSON ''"\u0020"'');
          concatLines_ = builtins.concatStringsSep "\n";
          greeterOutput_ = cfg.monitor.name;
          swayGreetConfig_ = let
            swayGreetCommand_ = builtins.concatStringsSep ";" [
              (concatWords_ [
                "${lib.getExe' pkgs.coreutils "env"}"
                "GTK_THEME=Adwaita:dark"
                "${lib.getExe pkgs.gtkgreet}"
                "-l"
              ])
              (concatWords_ [
                "${lib.getExe' config.programs.sway.package "swaymsg"} exit"
                ">/dev/null 2>&1 || true"
              ])
            ];
          in pkgs.writeText "greetd-sway-config" (concatLines_ [
            "output * bg #000000 solid_color"
            "focus output ${greeterOutput_}"
            "focus_on_window_activation none"
            "default_border none"
            "default_floating_border none"
            "titlebar_border_thickness 0"
            "titlebar_padding 0"
            "exec \"${swayGreetCommand_}\""
          ]);
          greetdCommand_ = concatWords_ [
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
            "${swayGreetConfig_}"
          ];
        in {
          user = "greeter";
          command = greetdCommand_;
        });
      };
    };
    
  };

}
