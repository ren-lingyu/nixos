{ lib, llib }: {
  mkLegacyPackages =
    pkgs:
    llib.packages.mkLegacyPackages {
      root = ./.;
      packagePath = "package.nix";
      inherit pkgs;
    };

  overlays =
    let
      assert_ =
        sets_:
        let
          names_ = builtins.concatMap builtins.attrNames (
            builtins.attrValues (builtins.removeAttrs sets_ [ "default" ])
          );
        in
        assert lib.assertMsg (
          builtins.length names_ == builtins.length (lib.unique names_)
        ) "Overlay sets_ must be pairwise disjoint.";
        assert lib.assertMsg (
          lib.subtractLists (builtins.attrNames sets_.default) names_ == [ ]
        ) "Overlay sets_ must be subsets of default.";
        lib.mapAttrs (_: value_: lib.composeManyExtensions (builtins.attrValues value_)) sets_;
    in
    assert_ (rec {
      default = llib.packages.mkOverlays {
        root = ./.;
        overlayPath = "overlay.nix";
      };

      share = builtins.removeAttrs default [ "rage-armored" ];
    });

  nixosModule = llib.packages.mkNixosModule {
    root = ./.;
    modulePath = "os/default.nix";
  };

  homeModule = llib.packages.mkHomeModule {
    root = ./.;
    modulePath = "hm/default.nix";
  };
}
