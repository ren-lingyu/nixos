{
  options,
  config,
  pkgs,
  lib,
  llib,
  ...
}:
let

  mif = llib.hosts;

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

in
{
  config = {
    networking.networkmanager = lib.mkIf enabledHost_.shared.networkmanager.enable { enable = true; };

    hardware.bluetooth = lib.mkIf enabledHost_.shared.bluetooth.enable {
      enable = enabledHost_.shared.bluetooth.enable;
      package = pkgs.bluez;
      powerOnBoot = true;
    };

    services.blueman = lib.mkIf enabledHost_.shared.bluetooth.enable { enable = true; };

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
