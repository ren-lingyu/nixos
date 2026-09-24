{ pkgs, lib, llib } : {

  legacyPackages = llib.packageFunctions.mkLegacyPackages {
    root = ./.;
    packagePath = "package.nix";
    inherit pkgs;
  };

  overlay = llib.packageFunctions.mkOverlay {
    root = ./.;
    overlayPath = "overlay.nix";
  };

  nixosModule = llib.packageFunctions.mkNixosModule {
    root = ./.;
    modulePath = "os/default.nix";
  };

  homeManagerModule = llib.packageFunctions.mkHomeManagerModule {
    root = ./.;
    modulePath = "hm/default.nix";
  };

}
