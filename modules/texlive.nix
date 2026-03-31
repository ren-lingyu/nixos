{ config, pkgs, ... }:

let

  luadraw = pkgs.arcc-nixpkgs.luadraw;
  
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full dvisvgm;
    inherit luadraw;
  };
  
in

{
  
  environment.systemPackages = [
    tex
  ];
  
}
