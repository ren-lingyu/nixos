{ config, lib, pkgs, osConfig, ... } : let

  noctaliaEnable = (
    osConfig.networking.networkmanager.enable
    &&
    osConfig.hardware.bluetooth.enable
    && (
      osConfig.services.power-profiles-daemon.enable
      ||
      osConfig.services.tuned.enable
    ) &&
    osConfig.services.upower.enable
  );
  
in {

  config = lib.mkIf noctaliaEnable {
    
    programs.noctalia-shell = {
      enable = true;
      settings = {
        
        settingsVersion = 0;

        noctaliaPerformance = {
          disableWallpaper = true;
          disableDesktopWidgets = true;
        };
        
        bar = {
          barType = "simple";
          position = "top";
          monitors = [ ];
          density = "default";
          showOutline = false;
          showCapsule = true;
          capsuleOpacity = 1;
          capsuleColorKey = "none";
          widgetSpacing = 6;
          contentPadding = 2;
          fontScale = 1;
          enableExclusionZoneInset = true;
          backgroundOpacity = 0.93;
          useSeparateOpacity = false;
          marginVertical = 4;
          marginHorizontal = 4;
          frameThickness = 8;
          frameRadius = 12;
          outerCorners = true;
          hideOnOverview = false;
          displayMode = "always_visible";
          autoHideDelay = 500;
          autoShowDelay = 150;
          showOnWorkspaceSwitch = true;
          widgets = {
            left = [
              {
                id = "NotificationHistory";
                showUnreadBadge = true;
                hideWhenZero = false;
                hideWhenZeroUnread = false;
                unreadBadgeColor = "primary";
                iconColor = "none";
              }
              # {
              #   id = "Launcher"; # appLauncher 由 niri "Mod+D" 启动, 不置于 bar.
              # }
              {
                id = "Tray";
                blacklist = [];
                colorizeIcons = false; # 是否用主题色彩覆盖 icons 色彩
                chevronColor = "none";
                pinned = [];
                drawerEnabled = true;
                hidePassive = false;
              }
              {
                id = "Workspace";
              }
              {
                id = "Taskbar";
                onlySameOutput = true;
                onlyActiveWorkspaces = true;
                hideMode = "hidden";
                colorizeIcons = false;
                showTitle = false;
                titleWidth = 120;
                showPinnedApps = true;
                smartWidth = true;
                maxTaskbarWidth = 40;
                iconScale = 0.8;
              }
              {
                id = "ActiveWindow";
                textColor = "none";
                showText = true;
                showIcon = false; # 如果启用显示 icon 会在没有程序运行于当前 window 时显示 debug 图标(左上角右下角黑色, 左下角右上角紫色).
                hideMode = "hidden";
                scrollingMode = "always";
                maxWidth = 300;
                useFixedWidth = false;
                colorizeIcons = false; # 是否用主题色彩覆盖 icons 色彩
              }
              {
                id = "MediaMini";
              }
            ];
            center = [
              {
                id = "Clock";
                clockColor = "none";
                useCustomFont = false;
                customFont = "";
                formatHorizontal = "yyyy-MM-dd, dddd, HH:mm:ss";
                formatVertical = "HH mm - dd MM";
                tooltipFormat = "yyyy-MM-dd, dddd, HH:mm:ss, tt";
              }
              {
                id = "SystemMonitor";
                compactMode = true;
                iconColor = "none";
                textColor = "none";
                useMonospaceFont = true;
                usePadding = false;
                showCpuUsage = true;
                showCpuCores = false;
                showCpuFreq = false;
                showCpuTemp = true;
                showGpuTemp = true;
                showLoadAverage = true;
                showMemoryUsage = true;
                showMemoryAsPercent = true;
                showSwapUsage = true;
                showNetworkStats = true;
                showDiskUsage = true;
                showDiskUsageAsPercent = true;
                showDiskAvailable = true;
                diskPath = "/";
              }
            ];
            right = [
              {
                id = "LockKeys";
                showCapsLock = true;
                showNumLock = false;
                showScrollLock = false;
                capsLockIcon = "letter-c";
                numLockIcon = "letter-n";
                scrollLockIcon = "letter-s";
                hideWhenOff = false;
              }
              {
                id = "DarkMode";
                iconColor = "none";
              }
              {
                id = "KeepAwake";
                iconColor = "none";
                textColor = "none";
              }
              {
                id = "KeyboardLayout";
                displayMode = "forceOpen";
                showIcon = false;
                iconColor = "none";
                textColor = "none";
              }
              {
                id = "Bluetooth";
                displayMode = "onhover";
                iconColor = "none";
                textColor = "none";
              }
              {
                id = "Network";
                displayMode = "alwaysShow";
                iconColor = "none";
                textColor = "none";
              }
              {
                id = "Volume";
                displayMode = "alwaysShow";
                middleClickCommand = "pwvucontrol || pavucontrol";
                iconColor = "none";
                textColor = "none";
              }
              {
                id = "Brightness";
                displayMode = "alwaysShow";
                iconColor = "none";
                textColor = "none";
                applyToAllMonitors = false;
              }
              {
                id = "Battery";
                displayMode = "icon-always";
                alwaysShowPercentage = true;
                showPowerProfiles = true;
                showNoctaliaPerformance = true;
                hideIfNotDetected = true;
                hideIfIdle = false;
              }
              {
                id = "ControlCenter";
                useDistroLogo = true;
                icon = "niri"; # "noctalia";
                customIconPath = "";
                colorizeDistroLogo = false;
                colorizeSystemIcon = "none";
                colorizeSystemText = "none";
                enableColorization = true;
              }
            ];
          };
          mouseWheelAction = "none";
          reverseScroll = false;
          mouseWheelWrap = true;
          middleClickAction = "none";
          middleClickFollowMouse = false;
          middleClickCommand = "";
          rightClickAction = "controlCenter";
          rightClickFollowMouse = true;
          rightClickCommand = "";
          screenOverrides = [ ];
        };
        
        general = {
          avatarImage = "";
          dimmerOpacity = 0.2;
          showScreenCorners = false;
          forceBlackScreenCorners = true;
          scaleRatio = 1;
          radiusRatio = 1;
          iRadiusRatio = 1;
          boxRadiusRatio = 1;
          screenRadiusRatio = 1;
          animationSpeed = 1;
          animationDisabled = true;
          compactLockScreen = true;
          lockScreenAnimations = false;
          lockOnSuspend = true;
          showSessionButtonsOnLockScreen = false;
          showHibernateOnLockScreen = false;
          enableLockScreenMediaControls = false;
          enableShadows = true;
          enableBlurBehind = true;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          language = "en";
          allowPanelsOnScreenWithoutBar = true;
          showChangelogOnStartup = true;
          telemetryEnabled = false;
          enableLockScreenCountdown = true;
          lockScreenCountdownDuration = 10000;
          autoStartAuth = false;
          allowPasswordWithFprintd = osConfig.services.fprintd.enable;
          clockStyle = "custom";
          clockFormat = "hh\nmm\nss";
          passwordChars = false;
          lockScreenMonitors = [ ];
          lockScreenBlur = 0.8;
          lockScreenTint = 0.8;
          keybinds = {
            keyUp = [
              "Up"
            ];
            keyDown = [
              "Down"
            ];
            keyLeft = [
              "Left"
            ];
            keyRight = [
              "Right"
            ];
            keyEnter = [
              "Return"
              "Enter"
            ];
            keyEscape = [
              "Esc"
            ];
            keyRemove = [
              "Del"
            ];
          };
          reverseScroll = false;
          smoothScrollEnabled = true;
        };
        
        ui = {
          fontDefault = "";
          fontFixed = "";
          fontDefaultScale = 1;
          fontFixedScale = 1;
          tooltipsEnabled = true;
          scrollbarAlwaysVisible = true;
          boxBorderEnabled = false;
          panelBackgroundOpacity = 0.93;
          translucentWidgets = false;
          panelsAttachedToBar = true;
          settingsPanelMode = "attached";
          settingsPanelSideBarCardStyle = false;
        };
        
        location = {
          name = "";
          weatherEnabled = true;
          weatherShowEffects = true;
          weatherTaliaMascotAlways = false;
          useFahrenheit = false;
          use12hourFormat = false;
          showWeekNumberInCalendar = false;
          showCalendarEvents = true;
          showCalendarWeather = true;
          analogClockInCalendar = false;
          firstDayOfWeek = -1;
          hideWeatherTimezone = false;
          hideWeatherCityName = false;
          autoLocate = true;
        };
        
        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
          ];
        };
        
        wallpaper = {
          enabled = true;
          overviewEnabled = false;
          directory = "";
          monitorDirectories = [ ];
          enableMultiMonitorDirectories = false;
          showHiddenFiles = false;
          viewMode = "single";
          setWallpaperOnAllMonitors = true;
          linkLightAndDarkWallpapers = true;
          fillMode = "crop";
          fillColor = "#000000";
          useSolidColor = true;
          solidColor = "#000000";
          automationEnabled = false;
          wallpaperChangeMode = "random";
          randomIntervalSec = 300;
          transitionDuration = 1500;
          transitionType = [
            "fade"
            "disc"
            "stripes"
            "wipe"
            "pixelate"
            "honeycomb"
          ];
          skipStartupTransition = false;
          transitionEdgeSmoothness = 0.05;
          panelPosition = "follow_bar";
          hideWallpaperFilenames = false;
          useOriginalImages = false;
          overviewBlur = 0.4;
          overviewTint = 0.6;
          useWallhaven = false;
          wallhavenQuery = "";
          wallhavenSorting = "relevance";
          wallhavenOrder = "desc";
          wallhavenCategories = "111";
          wallhavenPurity = "100";
          wallhavenRatios = "";
          wallhavenApiKey = "";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenResolutionHeight = "";
          sortOrder = "name";
          favorites = [ ];
        };
        
        appLauncher = {
          enableClipboardHistory = true;
          autoPasteClipboard = true;
          enableClipPreview = true;
          clipboardWrapText = true;
          enableClipboardSmartIcons = true;
          enableClipboardChips = true;
          clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
          clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
          position = "center";
          pinnedApps = [ ];
          sortByMostUsed = true;
          terminalCommand = "${lib.getExe config.programs.kitty.package} -e";
          customLaunchPrefixEnabled = false;
          customLaunchPrefix = "";
          viewMode = "list";
          showCategories = true;
          iconMode = "tabler";
          showIconBackground = false;
          enableSettingsSearch = true;
          enableWindowsSearch = true;
          enableSessionSearch = true;
          ignoreMouseInput = false;
          screenshotAnnotationTool = "";
          overviewLayer = false;
          density = "default";
        };
        
        controlCenter = {
          position = "close_to_bar_button";
          diskPath = "/";
          shortcuts = {
            left = [
              {
                id = "Network";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "WallpaperSelector";
              }
              {
                id = "NoctaliaPerformance";
              }
            ];
            right = [
              {
                id = "Notifications";
              }
              {
                id = "PowerProfile";
              }
              {
                id = "KeepAwake";
              }
              {
                id = "NightLight";
              }
            ];
          };
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "brightness-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
        };
        
        systemMonitor = {
          cpuWarningThreshold = 80;
          cpuCriticalThreshold = 90;
          tempWarningThreshold = 80;
          tempCriticalThreshold = 90;
          gpuWarningThreshold = 80;
          gpuCriticalThreshold = 90;
          memWarningThreshold = 80;
          memCriticalThreshold = 90;
          swapWarningThreshold = 80;
          swapCriticalThreshold = 90;
          diskWarningThreshold = 80;
          diskCriticalThreshold = 90;
          diskAvailWarningThreshold = 20;
          diskAvailCriticalThreshold = 10;
          batteryWarningThreshold = 10;
          batteryCriticalThreshold = 5;
          enableDgpuMonitoring = false;
          useCustomColors = false;
          warningColor = "";
          criticalColor = "";
          externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        };
        
        dock = {
          enabled = true;
          position = "bottom";
          displayMode = "auto_hide";
          dockType = "floating";
          backgroundOpacity = 1;
          floatingRatio = 1;
          size = 1;
          onlySameOutput = true;
          monitors = [ ];
          pinnedApps = [ ];
          colorizeIcons = true;
          showLauncherIcon = false;
          launcherPosition = "end";
          launcherUseDistroLogo = false;
          launcherIcon = "";
          launcherIconColor = "none";
          pinnedStatic = false;
          inactiveIndicators = false;
          groupApps = false;
          groupContextMenuMode = "extended";
          groupClickAction = "cycle";
          groupIndicatorStyle = "dots";
          deadOpacity = 0.6;
          animationSpeed = 1;
          sitOnFrame = false;
          showDockIndicator = false;
          indicatorThickness = 3;
          indicatorColor = "primary";
          indicatorOpacity = 0.6;
        };
        
        network = {
          bluetoothRssiPollingEnabled = false;
          bluetoothRssiPollIntervalMs = 60000;
          networkPanelView = "wifi";
          wifiDetailsViewMode = "grid";
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = false;
          disableDiscoverability = false;
          bluetoothAutoConnect = true;
        };
        
        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 10000;
          position = "center";
          showHeader = true;
          showKeybinds = true;
          largeButtonsStyle = true;
          largeButtonsLayout = "single-row";
          powerOptions = [
            {
              action = "lock";
              enabled = true;
              keybind = "1";
            }
            {
              action = "suspend";
              enabled = true;
              keybind = "2";
            }
            {
              action = "hibernate";
              enabled = true;
              keybind = "3";
            }
            {
              action = "reboot";
              enabled = true;
              keybind = "4";
            }
            {
              action = "logout";
              enabled = true;
              keybind = "5";
            }
            {
              action = "shutdown";
              enabled = true;
              keybind = "6";
            }
            {
              action = "rebootToUefi";
              enabled = true;
              keybind = "7";
            }
          ];
        };
        
        notifications = {
          enabled = true;
          enableMarkdown = false;
          density = "default";
          monitors = [ ];
          location = "top_right";
          overlayLayer = true;
          backgroundOpacity = 1;
          respectExpireTimeout = false;
          lowUrgencyDuration = 3;
          normalUrgencyDuration = 8;
          criticalUrgencyDuration = 15;
          clearDismissed = true;
          saveToHistory = {
            low = true;
            normal = true;
            critical = true;
          };
          sounds = {
            enabled = false;
            volume = 0.5;
            separateSounds = false;
            criticalSoundFile = "";
            normalSoundFile = "";
            lowSoundFile = "";
            excludedApps = "discord,firefox,chrome,chromium,edge";
          };
          enableMediaToast = false;
          enableKeyboardLayoutToast = true;
          enableBatteryToast = true;
        };
        
        osd = {
          enabled = true;
          location = "top_right";
          autoHideMs = 2000;
          overlayLayer = true;
          backgroundOpacity = 1;
          enabledTypes = [
            0
            1
            2
          ];
          monitors = [ ];
        };
        
        audio = {
          volumeStep = 2;
          volumeOverdrive = false;
          spectrumFrameRate = 30;
          visualizerType = "linear";
          spectrumMirrored = true;
          mprisBlacklist = [ ];
          preferredPlayer = "";
          volumeFeedback = false;
          volumeFeedbackSoundFile = "";
        };
        
        brightness = {
          brightnessStep = 2;
          enforceMinimum = true;
          enableDdcSupport = false;
          backlightDeviceMappings = [ ];
        };
        
        colorSchemes = {
          useWallpaperColors = true;
          predefinedScheme = "Ayu"; # ""Noctalia (default)";
          darkMode = true;
          schedulingMode = "off";
          manualSunrise = "06:30";
          manualSunset = "18:30";
          generationMethod = "tonal-spot";
          monitorForColors = "";
          syncGsettings = true;
        };
        
        templates = {
          activeTemplates = [ ];
          enableUserTheming = false;
        };
        
        nightLight = {
          enabled = false;
          forced = false;
          autoSchedule = true;
          nightTemp = "4000";
          dayTemp = "6500";
          manualSunrise = "06:30";
          manualSunset = "18:30";
        };
        
        hooks = {
          enabled = false;
          wallpaperChange = "";
          darkModeChange = "";
          screenLock = "";
          screenUnlock = "";
          performanceModeEnabled = "";
          performanceModeDisabled = "";
          startup = "";
          session = "";
          colorGeneration = "";
        };
        
        plugins = {
          autoUpdate = false;
          notifyUpdates = true;
        };
        
        idle = {
          enabled = false;
          lockTimeout = 300;
          screenOffTimeout = 600;
          suspendTimeout = 1800;
          fadeDuration = 5;
          screenOffCommand = builtins.concatStringsSep " && " [
            "${lib.getExe config.programs.niri.package} msg action power-off-monitors"
          ];
          lockCommand = builtins.concatStringsSep " && " [
            "${lib.getExe config.programs.swaylock.package} -f"
          ];
          suspendCommand = builtins.concatStringsSep " && " [
            "${pkgs.systemd}/bin/systemctl suspend"
          ];
          resumeScreenOffCommand = builtins.concatStringsSep " && " [
            "${lib.getExe config.programs.niri.package} msg action power-on-monitors"
          ];
          resumeLockCommand = builtins.concatStringsSep " && " [
            "${lib.getExe config.programs.swaylock.package} -f"
          ];
          resumeSuspendCommand = builtins.concatStringsSep " && " [
            "${lib.getExe config.programs.niri.package} msg action power-on-monitors"
          ];
          customCommands = "[]";
        };
        
        desktopWidgets = {
          enabled = true;
          overviewEnabled = true;
          gridSnap = false;
          gridSnapScale = false;
          monitorWidgets = [ ];
        };
        
      };
    };
    
  };

}
