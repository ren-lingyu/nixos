{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf config.programs.niri.enable {

    programs.niri.settings.animations = {
      enable = false;
      slowdown = null;
    };

  };

}
