{ config, lib, pkgs, osConfig, ... } : {

  config = lib.mkIf config.programs.niri.enable {

    programs.niri.settings.animations = {
      enable = false;
      slowdown = null;
    };

  };

}
