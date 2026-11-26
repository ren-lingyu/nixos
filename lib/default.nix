{ lib }: rec {
  hosts = import ./hosts.nix { inherit lib; };
  flakeParts = import ./flakeParts.nix {
    inherit lib;
    inherit (types) deferredModuleFragment;
    inherit (modules) mapModule;
  };
  identity = import ./identity.nix;
  modules = import ./modules.nix { inherit lib; };
  secrets = import ./secrets.nix { inherit lib; };
  types = import ./types.nix { inherit lib; };
}
