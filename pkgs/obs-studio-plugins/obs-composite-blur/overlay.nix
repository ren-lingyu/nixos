final_ : prev_ : {

  obs-composite-blur = final_.callPackage ./package.nix {
    obs-composite-blur = prev_.obs-composite-blur;
  };

}
