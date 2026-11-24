{ config, pkgs, ... }: {
  config = {
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
