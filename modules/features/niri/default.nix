{ config, pkgs, lib, ... } : let

  noctaliaEnable = (
    config.networking.networkmanager.enable
    &&
    config.hardware.bluetooth.enable
    && (
      config.services.power-profiles-daemon.enable
      ||
      config.services.tuned.enable
    ) &&
    config.services.upower.enable
  );
  
in {

  imports = [
    ./os
  ];

  config = {
    
    modules.features.niri.existModule = {
      os = true;
      hm = true;
    };
    
    assertions = [
      {
        assertion = !config.modules.features.niri.greeter.enable || config.modules.features.niri.enable;
        message = "`modules.features.niri.greeter.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = !config.modules.features.niri.waybar.enable || config.modules.features.niri.enable;
        message = "`modules.features.niri.waybar.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = !config.modules.features.niri.noctalia-shell.enable || config.modules.features.niri.enable;
        message = "`modules.features.niri.noctalia-shell.enable = true` is only allowed when `modules.features.niri.enable = true;`.";
      }
      {
        assertion = !config.modules.features.niri.noctalia-shell.enable || noctaliaEnable;
        message = "`modules.features.niri.noctalia-shell.enable = true` requires system-level features (NetworkManager, Bluetooth, power-profiles-daemon/tuned, UPower) to be enabled.";
      }
      {
        assertion = !(config.modules.features.niri.waybar.enable && config.modules.features.niri.noctalia-shell.enable);
        message = "`modules.features.niri.waybar.enable` and `modules.features.niri.noctalia-shell.enable` cannot be true simultaneously.";
      }
    ];
    
  };
  
}
