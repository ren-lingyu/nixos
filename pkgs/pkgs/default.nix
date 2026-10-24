{ llib }: {
  overlays = llib.packages.mkOverlays {
    root = ./.;
    overlayFile = "overlay.nix";
    groups = {
      legacy = {
        export = true;
      };

      share = {
        exclude = [ "rage-armored" ];
      };
    };
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
