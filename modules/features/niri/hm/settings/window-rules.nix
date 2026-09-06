{ config, lib, pkgs, osConfig, ... } : {

  config = lib.mkIf config.programs.niri.enable {

    programs.niri.settings.window-rules = [
      {
        matches = [
          { app-id = "Emacs"; }
        ];
        open-floating = false;
        open-maximized = true;
      }
      {
        matches = [
          { app-id = "^dev[.]noctalia[.]Noctalia$"; }
        ];
        open-floating = true;
        default-column-width = {
          fixed = 1080;
        };
        default-window-height = {
          fixed = 920;
        };
      }
    ];

  };

}
