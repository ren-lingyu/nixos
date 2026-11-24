{ lib }: {
  hosts = import ./hosts.nix { inherit lib; };
  flakeParts = import ./flakeParts.nix { inherit lib; };
}
