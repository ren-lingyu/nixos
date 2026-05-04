{ config, lib, pkgs, osConfig, ... } : {

  config = lib.mkIf config.programs.waybar.enable {
    
    programs.waybar.settings = [
      {
        
        height = 30;
        spacing = 4;
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;
        fixed-center = false;
        
        modules-left = [
          "niri/workspaces"
        ];

        modules-center = [
          "niri/window"
        ];

        modules-right = [
          "idle_inhibitor"
          "pulseaudio"
          "keyboard-state"
          "network"
          "power-profiles-daemon"
          "cpu"
          "memory"
          "temperature"
          "backlight"
          "battery"
          "battery#bat2"
          "clock"
          "tray"
          "custom/power"
        ];

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            focused = "";
            default = "";
          };
        };

        "niri/window" = {
          max-length = 50;
          format = "{}";
        };

        "keyboard-state" = {
          numlock = true;
          capslock = true;
          format = "{name} {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };
        
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        tray = {
          spacing = 4;
        };

        clock = {
          format = "{:%H:%M:%S}";
          tooltip-format = "{:%A %Y-%m-%d}\n{calendar}";
          format-alt = "{:%Y-%m-%d %H:%M:%S %Z}";
          interval = 1;
        };

        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };

        memory = {
          format = "{}% ";
        };

        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C";
          format-icons = [];
        };

        backlight = {
          format = "{percent}% {icon}";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰃨";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "battery#bat2" = {
          bat = "BAT2";
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} 󰊗";
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          format-linked = "{ifname} (No IP) 󰊗";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = "󰅶 {icon} {format_source}";
          format-muted = "󰅶 {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "󰂑";
            headset = "󰂑";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        "custom/power" = {
          format = ( " " + "⏻ " + " " );
          tooltip = false; 
          menu = "on-click";
          menu-file = "${config.xdg.configHome}/waybar/power-menu.xml";
          menu-actions = {
            shutdown = "shutdown";
            reboot = "reboot";
            suspend = "systemctl suspend";
            hibernate = "systemctl hibernate";
          };
        };
        
      }
    ];

    xdg.configFile."./waybar/power-menu.xml" = {
      enable = true;
      source = ./power-menu.xml;
      target = "./waybar/power-menu.xml";
      executable = true;
    };
    
  };

}
