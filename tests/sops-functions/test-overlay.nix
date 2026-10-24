{ }: final_: prev_: {
  sops-functions = final_.callPackage ./test.nix { features = final_.llibFeatures; };
}
