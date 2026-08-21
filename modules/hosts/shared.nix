{ options, config, pkgs, lib, llib, ... } : let

  mif = llib.moduleFunctions.hosts.default;

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

in {

  options = {

    modules.hosts = llib.moduleFunctions.default.mkModuleOptions.withoutExtra {
      path = ./.;
      commonSchema = (host_ : {

        shared = lib.mkOption {
          type = lib.types.submodule {
            options = {

              networkmanager = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  internal = true;
                  readOnly = true;
                  description = "Whether to enable NetworkManager for this host.";
                };
              };

              bluetooth = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  internal = true;
                  readOnly = true;
                  description = "Whether to enable Bluetooth and blueman for this host.";
                };
              };

              power = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  internal = true;
                  readOnly = true;
                  description = "Whether to enable power-profiles-daemon and UPower for this host.";
                };
              };

            };
          };
          default = {};
          description = "Shared system services for the ${host_} host.";
        };

      });
    };

  };

  config = {

    networking.networkmanager = lib.mkIf enabledHost_.shared.networkmanager.enable {
      enable = true;
    };

    hardware.bluetooth = lib.mkIf enabledHost_.shared.bluetooth.enable {
      enable = enabledHost_.shared.bluetooth.enable;
      package = pkgs.bluez;
      powerOnBoot = true;
    };

    services.blueman = lib.mkIf enabledHost_.shared.bluetooth.enable {
      enable = true;
    };

    services.power-profiles-daemon = lib.mkIf enabledHost_.shared.power.enable {
      enable = true;
      package = pkgs.power-profiles-daemon;
    };

    services.upower = lib.mkIf enabledHost_.shared.power.enable {
      enable = true;
      package = pkgs.upower;
      usePercentageForPolicy = true;
      percentageAction = 2;
      percentageCritical = 3;
      percentageLow = 10;
      timeAction = 120;
      timeCritical = 300;
      timeLow = 1200;
      criticalPowerAction = "HybridSleep"; # "PowerOff", "Hibernate", "HybridSleep"
      allowRiskyCriticalPowerAction = false;
      enableWattsUpPro = false;
      ignoreLid = false;
      noPollBatteries = false;
    };

  };

}
