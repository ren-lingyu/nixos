{ config, pkgs, lib, ... } : let

  luadraw = pkgs.arcc.texlivePackages.luadraw;
  
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full dvisvgm;
    inherit luadraw;
  };

  packages = with pkgs; [
    ghostscript
    mupdf
  ];
  
in {
  
  config = lib.mkIf config.modules.texlive.enable {
    environment.systemPackages = builtins.concatLists [
      [ tex ]
      packages
    ];
  };
  
}
