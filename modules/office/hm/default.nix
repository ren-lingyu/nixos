{ config, pkgs, lib, ... } : {

  config = {

    home.packages = with pkgs; [
      libreoffice-qt-fresh
    ];
    
    programs.onlyoffice = {
      enable = false;
      package = pkgs.onlyoffice-desktopeditors;
      settings = {
        UITheme = "theme-contrast-dark";
        editorWindowMode = false;
        locale = "zh-CN";
        titlebar = "custom";
      };
    };
    
  };

}
