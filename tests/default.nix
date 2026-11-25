{
  lib,
  pkgs,
  llib,
  modules,
  featureRegistry,
}:
llib.tests.mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";
  args = {
    inherit lib modules featureRegistry;
    featureTestPackages = {
      inherit (pkgs)
        bashInteractive
        zsh
        antidote
        starship
        ;
    };
    inherit (pkgs) runCommand;
    llibFlakeParts = llib.flakeParts;
    llibHosts = llib.hosts;
    llibTypes = llib.types;
  };
}
