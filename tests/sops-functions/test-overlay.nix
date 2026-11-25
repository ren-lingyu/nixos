{ }: final_: prev_: {
  sops-functions = final_.callPackage ./test.nix {
    secrets = import (final_.modules + "/features/sops/hm/secrets.nix");
    sops = final_.modules + "/features/sops/os";
  };
}
