{ config, lib, pkgs, ... } : {

  imports = [
    ./greeter.nix
  ];

  config = {
    
    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];
    
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    services.desktopManager.gnome.enable = lib.mkForce false;
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    
  };
  
}
