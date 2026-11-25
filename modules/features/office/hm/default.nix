{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.features.office.enable = lib.mkEnableOption "Home Manager office applications";

  config = lib.mkIf config.features.office.enable {
    programs.libreoffice = {
      enable = true;
      package = pkgs.libreoffice-qt-stable.override {
        extraMakeWrapperArgs = [
          "--set"
          "SAL_USE_VCLPLUGIN"
          "qt6"
        ];
      };
    };

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
