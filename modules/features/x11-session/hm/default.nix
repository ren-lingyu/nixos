{ config, osConfig, pkgs, lib, ... } : let

  cfg = osConfig.modules.features.x11-session;

in {

  config = lib.mkIf cfg.enable {

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
    };

  };

}
