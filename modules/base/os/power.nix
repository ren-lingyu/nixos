{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.base.power.enable = lib.mkOption {
    type = lib.types.bool;
    internal = true;
    readOnly = true;
    description = "Whether to apply the Base power management configuration.";
  };

  config = lib.mkIf config.base.power.enable {
    services.power-profiles-daemon = {
      enable = true;
      package = pkgs.power-profiles-daemon;
    };

    services.upower = {
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
