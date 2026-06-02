{ config, pkgs, lib, ... } : {

  options = {
    modules.office = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
  config = lib.mkIf config.modules.office.enable {

    home-manager.users = {
      "${builtins.toString config.modules.user.uid}" = {
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
    };
    
  };
  
}
