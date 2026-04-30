{ config, lib, pkgs, osConfig, ... } : {

  config = lib.mkIf config.programs.niri.enable {
    
    programs.niri.settings.window-rules = [
      {
        matches = [
          { app-id = "Enacs"; }
        ];
        open-floating = false;
        open-maximized = true;
      }
    ];
    
  };

}
