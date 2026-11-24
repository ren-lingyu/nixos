{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.features.media.enable = lib.mkEnableOption "Home Manager media configuration";

  config = lib.mkIf config.features.media.enable {
    programs.mpv = {
      enable = true;
      package = pkgs.mpv;

      config = {
        save-position-on-quit = true;
      };

      scripts = [ pkgs.mpvScripts.mpris ];
    };
  };
}
