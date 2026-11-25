{ lib }: rec {
  hosts = import ./hosts.nix { inherit lib; };
  flakeParts = import ./flakeParts.nix {
    inherit lib;
    inherit (types) featureModule;
  };
  types = import ./types.nix { inherit lib; };
}
