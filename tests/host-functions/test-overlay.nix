{ }: final_: prev_: {
  host-functions = final_.callPackage ./test.nix { hosts = final_.llibHosts; };
}
