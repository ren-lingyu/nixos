{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.features.x11-session.enable = lib.mkEnableOption "Home Manager X11 session integration";

  config = lib.mkIf config.features.x11-session.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
    };
  };
}
