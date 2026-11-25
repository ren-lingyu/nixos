{ lib }: rec {
  hosts = import ./hosts.nix { inherit lib; };
  flakeParts = import ./flakeParts.nix {
    inherit lib;
    inherit (types) deferredModuleFragment;
    inherit (modules) mapModule;
  };
  modules = import ./modules.nix { inherit lib; };
  types = import ./types.nix { inherit lib; };
}
