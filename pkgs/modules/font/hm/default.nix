{ osConfig, ... }: {
  config = {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = osConfig.fonts.fontconfig.defaultFonts;
    };
  };
}
