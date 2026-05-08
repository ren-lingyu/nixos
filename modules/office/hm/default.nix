{ config, pkgs, ... } : {

  config = {
    
    programs.onlyoffice = {
      enable = true;
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
