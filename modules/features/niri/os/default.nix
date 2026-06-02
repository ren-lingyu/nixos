{ config, pkgs, lib, ... } : {

  imports = [
    ./greeter.nix
  ];

  config = lib.mkIf config.modules.niri.enable {

    programs.niri = {
      enable = config.modules.niri.enable;
      package = pkgs.niri;
    };
    
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
    
    services.desktopManager.gnome.enable = lib.mkForce false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    
  };
  
}
