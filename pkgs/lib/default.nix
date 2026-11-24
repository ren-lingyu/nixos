{ lib }: {
  discoverModules = import ./discover-modules.nix { inherit lib; };
  types = import ./types.nix { inherit lib; };
}
