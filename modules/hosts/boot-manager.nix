{ options, config, pkgs, lib, llib, ... } : let

  mif = llib.moduleFunctions.hosts.default;

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

  defaultMonitorResolution_ = let
    defaults_ = (builtins.filter
      (monitor_ : monitor_.role == "default")
      (builtins.attrValues enabledHost_.monitors)
    );
  in (
    if builtins.length defaults_ == 1
    then let
      defaultMonitor_ = builtins.head defaults_;
    in "${builtins.toString defaultMonitor_.mode.width}x${builtins.toString defaultMonitor_.mode.height}"
    else null
  );

in {

  options = {

    modules.hosts = llib.moduleFunctions.default.mkModuleOptions.withoutExtra {
      path = ./.;
      commonSchema = (host_ : {

        bootManager = lib.mkOption {
          type = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                internal = true;
                readOnly = true;
                description = "Whether to apply the boot-manager template for the host ${host_}.";
              };
            };
          };
          default = {};
          description = "Boot-manager template configuration for the ${host_} host.";
        };

      });
    };

  };

  config = lib.mkIf enabledHost_.bootManager.enable {

    environment.systemPackages = (lib.optionals
      (config.boot.loader.limine.enable)
      (with pkgs; [
        sbctl
        efitools
      ])
    );

    boot.loader = {
      systemd-boot = {
        enable = lib.mkDefault false;
        consoleMode = "auto";
      };
      efi = {
        canTouchEfiVariables = lib.mkDefault false;
      };
      limine = {
        enable = lib.mkDefault false;
        package = pkgs.limine;
        resolution = defaultMonitorResolution_;
        efiSupport = true;
        validateChecksums = true;
        maxGenerations = null;
        extraEntries = lib.mkDefault "";
        secureBoot = {
          enable = lib.mkDefault false;
          sbctl = pkgs.sbctl;
          autoGenerateKeys = true;
          autoEnrollKeys = {
            enable = true;
            extraArgs =   [
              "--microsoft"
              "--firmware-builtin"
            ];
          };
        };
        style = {
          wallpapers = [];
          wallpaperStyle = "stretched"; # "stretched" or "tiled" or "centered"
          backdrop = "000000";
          interface = {
            resolution = defaultMonitorResolution_;
            helpHidden = false;
            brandingColor = "#000000";
            branding = "NixOS - Limine Bootloader";
          };
          graphicalTerminal = {
            palette = "000000;AA0000;00AA00;AA5500;0000AA;AA00AA;00AAAA;AAAAAA";
            brightPalette = "555555;FF5555;55FF55;FFFF55;5555FF;FF55FF;55FFFF;FFFFFF";
            foreground = "FFFFFF";
            background = "000000";
            brightForeground = "FFFF55";
            brightBackground = "0000AA";
            margin = 0;
            marginGradient = 0;
            font = {
              spacing = 0;
              scale = null;
            };
          };
        };
      };
    };

  };

}
