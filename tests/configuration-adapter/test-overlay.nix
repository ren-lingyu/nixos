{ }: final: prev: {
  configuration-adapter = final.callPackage ./test.nix {
    flakeParts = final.llibFlakeParts;
    modules = final.llibModules;
    types = final.llibTypes;
  };
}
