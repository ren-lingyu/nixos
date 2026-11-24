{
  options,
  config,
  host,
  pkgs,
  lib,
  ...
}:
{
  config = {
    networking.networkmanager = lib.mkIf host.shared.networkmanager.enable { enable = true; };

    hardware.bluetooth = lib.mkIf host.shared.bluetooth.enable {
      enable = host.shared.bluetooth.enable;
      package = pkgs.bluez;
      powerOnBoot = true;
    };

    services.blueman = lib.mkIf host.shared.bluetooth.enable { enable = true; };

    services.power-profiles-daemon = lib.mkIf host.shared.power.enable {
      enable = true;
      package = pkgs.power-profiles-daemon;
    };

    services.upower = lib.mkIf host.shared.power.enable {
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
