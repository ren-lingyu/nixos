{ }: final_: prev_: {
  lib-modules = final_.callPackage ./test.nix { inherit (final_.llibModules) mapModule; };
}
