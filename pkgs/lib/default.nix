{ lib }: rec {

  packages = import ./packages.nix { inherit lib; };

}
