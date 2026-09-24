{ pkgs, lib, llib } : {

  legacyPackages = llib.packageFunctions.mkLegacyPackages {
    root = ./.;
    inherit pkgs;
  };

  overlay = llib.packageFunctions.mkOverlay {
    root = ./.;
  };

}
