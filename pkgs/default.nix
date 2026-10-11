{ llib }: {

  mkLegacyPackages =
    pkgs:
    llib.packages.mkLegacyPackages {
      root = ./.;
      packagePath = "package.nix";
      inherit pkgs;
    };

  overlay = llib.packages.mkOverlay {
    root = ./.;
    overlayPath = "overlay.nix";
  };

  nixosModule = llib.packages.mkNixosModule {
    root = ./.;
    modulePath = "os/default.nix";
  };

  homeModule = llib.packages.mkHomeModule {
    root = ./.;
    modulePath = "hm/default.nix";
  };

}
