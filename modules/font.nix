{ config, pkgs, ... }:

{

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      wqy_zenhei
      nerd-fonts.meslo-lg
      liberation_ttf
      arphic-ukai
      arphic-uming
      maple-mono.truetype
      maple-mono.NF-CN
      maple-mono.NF-CN-unhinted
    ];
    fontDir = {
      enable = true;
    };
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        emoji = [ "Maple Mono NF CN" ];
        monospace = [ "Maple Mono NF CN" ];
        sansSerif = [ "Maple Mono NF CN" ];
        serif = [ "Maple Mono NF CN" ];
      };
    };
  };
  
}
