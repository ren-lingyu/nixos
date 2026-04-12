{ config, pkgs, ... } : {

  fonts = {
    packages = with pkgs; [
      adwaita-fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      wqy_zenhei
      nerd-fonts.symbols-only
      nerd-fonts.meslo-lg
      liberation_ttf
      arphic-ukai
      arphic-uming
      maple-mono.variable
      maple-mono.truetype
      maple-mono.NF-CN
      maple-mono.NF-CN-unhinted
      source-code-pro
      hack-font
      jetbrains-mono
    ];
    fontDir = {
      enable = true;
    };
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        emoji = [
          "Noto Color Emoji" 
          "Maple Mono NF CN"
        ];
        monospace = [
          "Maple Mono NF CN"
          "Noto Sans Mono CJK SC"
          "Sarasa Mono SC"
          "DejaVu Sans Mono"
        ];
        sansSerif = [
          "Maple Mono NF CN"
          "Noto Sans CJK SC"
          "Source Han Sans SC"
          "DejaVu Sans"
        ];
        serif = [
          "Maple Mono NF CN"
          "Noto Serif CJK SC"
          "Source Han Serif SC"
          "DejaVu Serif"          
        ];
      };
    };
  };
  
}
