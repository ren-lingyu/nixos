{ config, osConfig, lib, pkgs, ... } : let

  cfg = osConfig.modules.features.niri;

in {

  config = lib.mkIf (builtins.all
    (x_ : x_)
    [
      cfg.enable
      cfg.noctalia.enable
    ]
  ) {

    programs.noctalia = {

      enable = cfg.noctalia.enable;
      settings = {

        accessibility = {
          ui_scale = 1.0;
        };

        shell = {

          corner_radius_scale = 1.0;
          font_family = (
            if builtins.elem pkgs.lxgw-wenkai osConfig.fonts.packages
            then "LXGW WenKai"
            else "sans-serif"
          );
          time_format = "{:%H:%M}";
          date_format = "%Y-%m-%d";
          offline_mode = false;
          telemetry_enabled = false;
          niri_overview_type_to_launch_enabled = false;
          polkit_agent = false;
          password_style = "default";
          settings_show_advanced = true;
          setup_wizard_enabled = false;
          show_location = true;
          clipboard_enabled = true;
          clipboard_keep_from_closed_apps = true;
          clipboard_auto_paste = "auto";
          clipboard_image_action_command = "";
          shared_gl_context = true;
          lang = "en";
          avatar_path = "";

          animation = {
            enabled = false;
            speed = 1.0;
          };

          shadow = {
            direction = "center";
            alpha = 0.55;
          };

          panel = {
            transparency_mode = "solid";
            borders = false;
            shadow = false;
            launcher_placement = "floating";
            clipboard_placement = "floating";
            control_center_placement = "attached";
            wallpaper_placement = "attached";
            session_placement = "attached";
            launcher_position = "center";
            clipboard_position = "center";
            control_center_position = "auto";
            wallpaper_position = "auto";
            session_position = "auto";
            open_near_click_control_center = true;
            open_near_click_launcher = false;
            open_near_click_clipboard = false;
            open_near_click_wallpaper = false;
            open_near_click_session = false;
          };

          launcher = {

            categories = true;
            show_icons = true;
            show_app_origin_indicator = true;
            compact = false;
            app_grid = false;
            sort_by_usage = true;
            pinned = [ ];
            fetch_exchange_rates = true;
            provider_prefix = "/";
            auto_paste = "auto";

            providers = {

              calculator = {
                prefix = "calc";
                global = true;
              };

              emoji = {
                prefix = "emo";
              };

              session = {
                prefix = "session";
                global = true;
              };

              wallpaper = {
                prefix = "wall";
              };

              windows = {
                prefix = "win";
                global = true;
              };

            };

          };

          mpris = {
            blacklist = [ ];
          };

          session = {

            grid = false;
            grid_columns = 3;
            show_shortcuts = true;

            actions = [
              {
                action = "lock";
                enabled = true;
                variant = "default";
                shortcut = "1";
                countdown_seconds = 10.0;
              }
              {
                action = "suspend";
                enabled = true;
                variant = "default";
                shortcut = "2";
                countdown_seconds = 10.0;
              }
              {
                action = "command";
                enabled = true;
                command = "${pkgs.systemd}/bin/systemctl hibernate";
                label = "Hibernate";
                variant = "default";
                shortcut = "3";
                countdown_seconds = 10.0;
              }
              {
                action = "reboot";
                enabled = true;
                variant = "default";
                shortcut = "4";
                countdown_seconds = 10.0;
              }
              {
                action = "logout";
                enabled = true;
                variant = "default";
                shortcut = "5";
                countdown_seconds = 10.0;
              }
              {
                action = "shutdown";
                enabled = true;
                variant = "destructive";
                shortcut = "6";
                countdown_seconds = 10.0;
              }
              {
                action = "command";
                enabled = true;
                command = "${pkgs.systemd}/bin/systemctl reboot --firmware-setup";
                label = "Reboot to UEFI";
                variant = "default";
                shortcut = "7";
                countdown_seconds = 10.0;
              }
            ];

          };

        };

        bar = {

          main = {

            position = "top";
            auto_hide = false;
            smart_auto_hide = false;
            show_on_workspace_switch = true;
            reserve_space = true;
            layer = "top";
            thickness = 34;
            background_opacity = 1.0;
            border_width = 0.0;
            radius = 0;
            radius_top_left = 0;
            radius_top_right = 0;
            radius_bottom_left = 12;
            radius_bottom_right = 12;
            concave_edge_corners = true;
            margin_ends = 0;
            margin_edge = 0;
            margin_opposite_edge = 0;
            padding = 2;
            widget_spacing = 2; #
            shadow = false;
            contact_shadow = false;
            scale = 1.0;
            font_scale = 1.0;
            capsule = true;
            capsule_opacity = 1.0;

            start = [
              "notifications"
              # "launcher" # appLauncher 由 niri "Mod+D" 启动, 不置于 bar.
              "tray"
              "workspaces"
              "taskbar"
              "active_window"
              "media"
            ];

            center = [
              "clock"
              "cpu_usage"
              "cpu_temp"
              # "gpu_usage"
              # "gpu_temp"
              "ram_usage"
              "swap_usage"
              "network_rx"
              "network_tx"
              "disk_usage"
              # "disk_available"
            ];

            end = [
              "lock_keys"
              "theme_mode"
              "caffeine"
              "keyboard_layout"
              "bluetooth"
              "network"
              "volume"
              "brightness"
              "battery"
              "control-center"
            ];

            dead_zone = {
              actions = {
                middle = "none";
                right = "panel-toggle control-center";
                scroll_up = "none";
                scroll_down = "none";
              };
            };

          };

        };

        widget = {

          notifications = {
            hide_when_no_unread = false;
          };

          tray = {
            hidden = [ ];
            pinned = [ ];
            hide_passive = false;
            match_adjacent_spacing = false;
            drawer = true;
            drawer_columns = 3;
            detached_panel = false;
          };

          taskbar = {
            pinned = [ ];
            taskbar_max_width = 40;
            group_by_workspace = false;
            show_all_outputs = false;
            only_active_workspace = true;
            icon_scale = 1.0;
            item_spacing = 2;
            show_window_title = false;
            window_title_max_width = 20;
            show_active_indicator = false;
            active_opacity = 1.0;
            inactive_opacity = 0.6;
          };

          active_window = {
            min_length = 80;
            max_length = 300;
            icon_size = 14;
            title_scroll = "always";
            display = "text_only"; # v4 遗留注释 # 如果启用显示 icon 会在没有程序运行于当前 window 时显示 debug 图标 (左上角右下角黑色, 左下角右上角紫色).
            show_empty_label = false;
          };

          media = {
            hide_when_no_media = true;
          };

          clock = {
            format = "{:%Y-%m-%d, %A, %H:%M:%S}";
            vertical_format = "{:%H %M - %d %m}";
            tooltip_format = "{:%Y-%m-%d, %A, %H:%M:%S, %p}";
          };

          cpu_usage = {
            type = "sysmon";
            stat = "cpu_usage";
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          cpu_temp = {
            type = "sysmon";
            stat = "cpu_temp";
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          gpu_usage = {
            type = "sysmon";
            stat = "gpu_usage";
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          gpu_temp = {
            type = "sysmon";
            stat = "gpu_temp";
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          ram_usage = {
            type = "sysmon";
            stat = "ram_pct";
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          swap_usage = {
            type = "sysmon";
            stat = "swap_pct";
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          network_rx = {
            type = "sysmon";
            stat = "net_rx";
            interface = "";
            network_speed_unit = "auto";
            network_speed_compact = false;
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          network_tx = {
            type = "sysmon";
            stat = "net_tx";
            interface = "";
            network_speed_unit = "auto";
            network_speed_compact = false;
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          disk_usage = {
            type = "sysmon";
            stat = "disk_used_pct";
            path = "/";
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          disk_available = {
            type = "sysmon";
            stat = "disk_free";
            path = "/";
            visualization = "gauge";
            show_value = false;
            label_show_units = true;
            show_glyph = true;
          };

          lock_keys = {
            display = "short";
            show_caps_lock = true;
            show_num_lock = false;
            show_scroll_lock = false;
            hide_when_off = false;
          };

          keyboard_layout = {
            display = "short";
            show_glyph = false;
            show_label = true;
            hide_when_single_layout = false;
          };

          bluetooth = {
            show_label = false;
            hide_when_adapter_off = false;
            hide_when_no_connected_device = false;
          };

          network = {
            show_label = true;
            vpn_status = "replace";
            show_vpn_label = false;
          };

          volume = {
            show_label = true;
            actions = {
              middle = "exec pwvucontrol || pavucontrol";
              scroll_up = "volume-up 2%";
              scroll_down = "volume-down 2%";
            };
          };

          brightness = {
            show_label = true;
            actions = {
              scroll_up = "brightness-up 2%";
              scroll_down = "brightness-down 2%";
            };
          };

          battery = {
            display_mode = "glyph";
            show_label = true;
            label_content = "percent";
            hide_when_plugged = false;
            hide_when_full = false;
          };

          control-center = {
            custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            custom_image_colorize = true;
          };

        };

        wallpaper = {

          enabled = false;
          fill_mode = "crop";
          fill_color = "#000000";
          transition = [
            "fade"
            "disc"
            "stripes"
            "wipe"
            "honeycomb"
          ];
          transition_duration = 1500;
          edge_smoothness = 0.05;
          transition_on_startup = true;
          directory = "";
          directory_light = "";
          directory_dark = "";
          per_monitor_directories = false;

          default = {
            path = "";
          };

          automation = {
            enabled = false;
            interval_seconds = 300;
            order = "random";
            recursive = true;
          };

        };

        backdrop = {
          enabled = false;
          blur_intensity = 0.4;
          tint_intensity = 0.6;
        };

        theme = {
          mode = "dark";
          shell_mode = "follow";
          source = "builtin";
          builtin = "Ayu"; # "Noctalia";
          wallpaper_scheme = "m3-tonal-spot";
          pure_black_dark = false;
          templates = {
            enable_builtin_templates = false;
            builtin_ids = [ ];
            enable_community_templates = false;
            community_ids = [ ];
          };
        };

        lockscreen = {
          enabled = true;
          lock_before_suspend = true;
          fingerprint = osConfig.services.fprintd.enable;
          allow_empty_password = false;
          blurred_desktop = true;
          blur_intensity = 0.8;
          tint_intensity = 0.8;
          wallpaper = "";
          monitors = [ ];
        };

        location = {
          auto_locate = true;
          address = "";
          custom_schedule = false;
          sunrise = "06:30";
          sunset = "18:30";
        };

        weather = {
          enabled = true;
          refresh_minutes = 30;
          unit = "celsius";
          effects = true;
        };

        calendar = {
          enabled = true;
          refresh_minutes = 15;
          event_date_format = "%A %e %B";
          event_time_format = "%H:%M";
        };

        control_center = {

          sidebar = "compact";
          sidebar_section = "compact";
          show_shortcut_labels = true;
          show_session_button = true;
          hidden_tabs = [ ];

          shortcuts = [
            {
              type = "wifi";
            }
            {
              type = "bluetooth";
            }
            {
              type = "wallpaper";
            }
            {
              type = "notification";
            }
            {
              type = "power_profile";
            }
            {
              type = "nightlight";
            }
          ];

          calendar = {
            show_events_card = true;
            show_week_numbers = false;
          };

        };

        system = {
          monitor = {
            enabled = true;
            cpu_usage_activity_threshold = 80;
            cpu_usage_critical_threshold = 90;
            cpu_temp_activity_threshold = 80;
            cpu_temp_critical_threshold = 90;
            gpu_usage_activity_threshold = 80;
            gpu_usage_critical_threshold = 90;
            gpu_temp_activity_threshold = 80;
            gpu_temp_critical_threshold = 90;
            ram_pct_activity_threshold = 80;
            ram_pct_critical_threshold = 90;
            swap_pct_activity_threshold = 80;
            swap_pct_critical_threshold = 90;
            disk_used_pct_activity_threshold = 80;
            disk_used_pct_critical_threshold = 90;
          };
        };

        notification = {
          enable_daemon = true;
          show_app_name = true;
          show_actions = true;
          position = "top_left";
          layer = "overlay";
          scale = 1.0;
          background_opacity = 1.0;
          border = false;
          offset_x = 20;
          offset_y = 8;
          monitors = [ ];
          collapse_on_dismiss = true;
          history_retention_hours = 0;
          max_visible = 0;
        };

        osd = {

          position = "top_right";
          position_vertical = "top_center";
          orientation = "horizontal";
          scale = 1.0;
          background_opacity = 1.0;
          border = false;
          offset_x = 20;
          offset_y = 8;
          monitors = [ ];

          kinds = {
            volume = true;
            volume_output = true;
            volume_input = true;
            brightness = true;
            media = false;
            wifi = false;
            bluetooth = false;
            power_profile = false;
            caffeine = false;
            nightlight = false;
            dnd = false;
            lock_keys = true;
            keyboard_layout = true;
            keyboard_backlight = false;
            privacy = false;
          };

        };

        audio = {
          enable_overdrive = false;
          enable_sounds = false;
          sound_volume = 0.5;
          volume_change_sound = "";
          notification_sound = "";
        };

        brightness = {
          enable_ddcutil = false;
          sync_all_monitors = false;
          ignore_mmids = [ ];
        };

        battery = {
          warning_threshold = 10;
        };

        nightlight = {
          enabled = false;
          force = false;
          temperature_night = 4000;
          temperature_day = 6500;
        };

        plugins = {
          enabled = [ ];
          auto_update = "none";
        };

        idle = {
          pre_action_fade_seconds = 5.0;
          behavior = {
            lock = {
              enabled = false;
              timeout = 300;
              action = "lock";
            };
            screen-off = {
              enabled = false;
              timeout = 600;
              action = "screen_off";
            };
            suspend = {
              enabled = false;
              timeout = 1800;
              action = "suspend";
              lock_before_suspend = true;
            };
          };
        };

        keybinds = {

          validate = [
            "return"
            "kp_enter"
          ];

          cancel = [
            "escape"
          ];

          left = [
            "left"
          ];

          right = [
            "right"
          ];

          up = [
            "up"
          ];

          down = [
            "down"
          ];

          tab_next = [
            "tab"
          ];

          tab_previous = [
            "shift+iso_left_tab"
          ];

          delete = [
            "del"
          ];

        };

        dock = {
          enabled = false;
          position = "bottom";
          active_monitor_only = true;
          monitors = [ ];
          icon_size = 48;
          main_axis_padding = 16;
          cross_axis_padding = 8;
          item_spacing = 6;
          background_opacity = 1.0;
          radius = 16;
          radius_top_left = 16;
          radius_top_right = 16;
          radius_bottom_left = 16;
          radius_bottom_right = 16;
          margin_ends = 0;
          margin_edge = 8;
          shadow = false;
          show_running = true;
          auto_hide = true;
          smart_auto_hide = false;
          reserve_space = false;
          layer = "top";
          active_scale = 1.0;
          inactive_scale = 0.85;
          magnification = false;
          active_opacity = 1.0;
          inactive_opacity = 0.6;
          show_dots = false;
          show_instance_count = false;
          launcher_position = "none";
          launcher_icon = "grid-dots";
          pinned = [ ];
        };

        hooks = {
        };

        desktop_widgets = {
          enabled = false;
        };

      };

    };

  };

}
