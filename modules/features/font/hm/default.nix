{
  osConfig,
  config,
  lib,
  ...
}:
{
  options.features.font.enable = lib.mkEnableOption "Home Manager font configuration";

  config = lib.mkIf config.features.font.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = osConfig.fonts.fontconfig.defaultFonts;
    };
  };
}
