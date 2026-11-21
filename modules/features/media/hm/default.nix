{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  cfg = osConfig.modules.features.media;
in
{
  config = lib.mkIf cfg.enable {
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
