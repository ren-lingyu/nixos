{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.niri;

in {
  
  config = lib.mkIf cfg.enable {

    programs.niri = {
      enable = cfg.enable;
      package = pkgs.niri;
    };
    
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
    
    services.desktopManager.gnome.enable = lib.mkForce false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    
  };
  
}
