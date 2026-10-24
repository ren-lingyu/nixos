{ llib }: {
  overlays = llib.packages.mkOverlays {
    root = ./.;
    overlayFile = "overlay.nix";
    groups = {
      default = { };

      share = {
        exclude = [ "rage-armored" ];
      };

      legacy = {
        export = true;
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
