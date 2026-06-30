{ config, pkgs, lib, ... } : {
  
  config = lib.mkIf config.modules.features.texlive.enable {
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
