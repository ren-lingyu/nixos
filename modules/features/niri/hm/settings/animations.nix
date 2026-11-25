{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf (config.features.niri.enable && config.programs.niri.enable) {
    programs.niri.settings.animations = {
      enable = false;
      slowdown = null;
    };
  };
}
