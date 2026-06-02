{ config, pkgs, lib, ... } : {

  options = {
    modules.features.office = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
      };
    };
  };
  
  config = lib.mkIf config.modules.features.office.enable {

    home-manager.users = {
      "${builtins.toString config.modules.users.uid}" = {
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
