{ llib }: {

  mkLegacyPackages =
    pkgs:
    llib.packageFunctions.mkLegacyPackages {
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

  homeModule = llib.packageFunctions.mkHomeModule {
    root = ./.;
    modulePath = "hm/default.nix";
  };

}
