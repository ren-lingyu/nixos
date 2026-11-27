{ }: final_: prev_: {
  configurations = final_.callPackage ./test.nix {
    flakeParts = final_.llibFlakeParts;
    hosts = final_.llibHosts;
    types = final_.llibTypes;
    identity = final_.llibIdentity;
    secrets = final_.llibSecrets;
  };
}
