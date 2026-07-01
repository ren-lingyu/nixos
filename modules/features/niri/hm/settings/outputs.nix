{ config, lib, pkgs, osConfig, ... } : let
  
  cfg = osConfig.modules.features.niri;

  monitorRoleToOutputList_ = {
    "default" = [ "default" ];
  };
  
in {

  config = lib.mkIf config.programs.niri.enable {
    
    programs.niri.settings.outputs = lib.foldlAttrs (x_ : hostMonitorName_ : hostMonitor_ : (builtins.foldl' (y_ : niriOutput_ : (y_ // {
      "${niriOutput_}" = lib.foldl' lib.recursiveUpdate { } [
        {
          name = hostMonitor_.name;
          enable = true;
          focus-at-startup = false;
          transform = {
            rotation = 0;
            flipped = false;
          };
        }
        (lib.optionalAttrs (hostMonitor_.width != null && hostMonitor_.height != null) {
          mode = {
            width = hostMonitor_.width;
            height = hostMonitor_.height;
          } // lib.optionalAttrs (hostMonitor_.refresh != null) {
            refresh = hostMonitor_.refresh;
          };
        })
        (lib.optionalAttrs (hostMonitor_.scale != null) {
          scale = hostMonitor_.scale;
        })
        (lib.optionalAttrs (hostMonitor_.role == "default") {
          focus-at-startup = true;
          position = {
            x = 0;
            y = 0;
          };
        })
      ];
    })) x_ ( [ hostMonitor_.name ] ))) { } cfg.monitors;
    
  };

}
