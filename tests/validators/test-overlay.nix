{ }: final_: prev_: {
  validators = final_.callPackage ./test.nix {
    flakeParts = final_.llibFlakeParts;
    moduleLib = final_.llibModules;
    types = final_.llibTypes;
  };
}
