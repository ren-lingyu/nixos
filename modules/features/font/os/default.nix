{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.font;

in {

  config = lib.mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        lxgw-wenkai
        lxgw-neoxihei
        lxgw-wenkai-screen
        lxgw-wenkai-tc
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
        dejavu_fonts
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
            "LXGW WenKai Mono"
            "Noto Sans Mono CJK SC"
            "Sarasa Mono SC"
            "DejaVu Sans Mono"
          ];
          sansSerif = [
            "LXGW WenKai"
            "Noto Sans CJK SC"
            "Source Han Sans SC"
            "DejaVu Sans"
            "Maple Mono NF CN"
          ];
          serif = [
            "LXGW WenKai"
            "Noto Serif CJK SC"
            "Source Han Serif SC"
            "DejaVu Serif"
            "Maple Mono NF CN"
          ];
        };
        localConf = builtins.concatStringsSep "\n" [
          "<?xml version=\"1.0\"?>"
          "<!DOCTYPE fontconfig SYSTEM \"urn:fontconfig:fonts.dtd\">"
          "<fontconfig>"
          "<dir>/usr/local/share/fonts</dir>"
          "</fontconfig>"
        ];
      };
    };
  };
  
}
