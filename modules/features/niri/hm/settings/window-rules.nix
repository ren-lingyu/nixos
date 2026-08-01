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
    ];

  };

}
