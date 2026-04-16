{ config, lib, pkgs, ... } : let

  niriAdditionEnable = ( config.programs.niri.enable && !config.services.desktopManager.gnome.enable );
  
in {

  services = lib.mkIf niriAdditionEnable {
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

  security = lib.mkIf niriAdditionEnable {
    polkit.enable = true;
    pam.services.swaylock = {};
  };

  programs = lib.mkIf niriAdditionEnable {
    waybar.enable = true;
  };

  environment.systemPackages = with pkgs; lib.mkIf niriAdditionEnable [
    fuzzel
    swaylock
    mako
    swayidle
  ];
  
}
