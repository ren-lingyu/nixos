{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.features.texlive.enable = lib.mkEnableOption "system TeX Live configuration";

  config = lib.mkIf config.features.texlive.enable {
    environment.systemPackages = with pkgs; [
      (texliveFull.withPackages (
        ps_: with ps_; [
          dvisvgm
          luadraw
        ]
      ))
      ghostscript
      mupdf
    ];
  };
}
