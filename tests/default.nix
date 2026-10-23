{
  lib,
  pkgs,
  llib,
  rootPath,
}:
llib.tests.mkChecks {
  root = ./.;
  overlayFile = "test-overlay.nix";
  separator = "-";
  args = {
    inherit lib rootPath;
    inherit (pkgs) runCommand;
    llibFeatures = llib.features;
    llibFlakeParts = llib.flakeParts;
    llibHosts = llib.hosts;
    llibModules = llib.modules;
    llibTypes = llib.types;
  };
}
