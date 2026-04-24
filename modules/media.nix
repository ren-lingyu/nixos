{ config, pkgs, lib, ... } : {
  
  config = {
    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-composite-blur
      ];
    };
  };
  
}
