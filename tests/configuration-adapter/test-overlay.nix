{ }: final_: prev_: {
  configuration-adapter = final_.callPackage ./test.nix {
    flakeParts = final_.llibFlakeParts;
    moduleLib = final_.llibModules;
    types = final_.llibTypes;
  };
}
