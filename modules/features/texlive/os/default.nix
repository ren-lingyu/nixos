{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.texlive;

in {
  
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (texlive.combined.scheme-full.withPackages (ps_ : with ps_; [
        dvisvgm
        luadraw
      ]))
      ghostscript
      mupdf
    ];
  };
  
}
