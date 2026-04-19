{ config, lib, pkgs, ... } : let

  niriAdditionEnable = ( config.programs.niri.enable && !config.services.desktopManager.gnome.enable );
  
in {

  config = lib.mkIf niriAdditionEnable {
    
    services = {
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      greetd = lib.mkIf (!config.services.displayManager.gdm.enable) {
        enable = config.programs.niri.enable;
        package = pkgs.greetd;
        settings = {
          default_session = {
            command = "${config.programs.niri.package}/bin/niri-session";
            user = "lingyu";
          };
        };
      };
    };

    security = {
      polkit.enable = true;
      pam.services.swaylock = {};
    };

    programs = {
      waybar.enable = true;
    };

    environment.systemPackages = with pkgs; [
      fuzzel
      swaylock
      mako
      swayidle
    ];
    
  };
  
}
