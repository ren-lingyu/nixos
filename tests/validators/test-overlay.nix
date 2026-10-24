{ }: final: prev: {
  validators = final.callPackage ./test.nix {
    flakeParts = final.llibFlakeParts;
    moduleLib = final.llibModules;
    types = final.llibTypes;
  };
}
