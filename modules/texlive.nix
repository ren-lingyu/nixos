{ config, pkgs, ... }:

let

  luadraw = pkgs.arcc-nixpkgs.texlivePackages.luadraw;
  
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full dvisvgm;
    inherit luadraw;
  };

  packages = with pkgs; [
    ghostscript
    mupdf
  ];
  
in

{
  
  environment.systemPackages = builtins.concatLists [
    [ tex ]
    packages
  ];
  
}
