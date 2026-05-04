{ config, pkgs, lib, ... } : {
  
  config = {

    # boot = {
    #   extraModulePackages = with config.boot.kernelPackages; [
    #     v4l2loopback
    #   ];
    #   kernelModules = [
    #     "v4l2loopback"
    #   ];
    #   extraModprobeConfig = "options v4l2loopback devices=1 video_nr=1 card_label=\"OBS Cam\" exclusive_caps=1";
    # };
    
    environment.systemPackages = with pkgs; [
      libva-utils
      ffmpeg
    ];

    services.pipewire = {
      enable = true;
      pulse = {
        enable = true;
      };
      alsa = {
        enable = true;
        support32Bit = true;
      };
      wireplumber = {
        enable = true;
        package = pkgs.wireplumber;
      };
    };
    
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
