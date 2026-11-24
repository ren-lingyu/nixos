{
  lib,
  runCommand,
  discoverModules,
  mergeAttrsRecursive,
}:
let
  root = ./discovery;
  os = discoverModules {
    inherit root;
    modulePath = "os/default.nix";
  };
  hm = discoverModules {
    inherit root;
    modulePath = "hm/default.nix";
  };
  result = lib.evalModules { modules = [ os.sample ]; };
  collision = builtins.tryEval (
    (mergeAttrsRecursive { allowOverrides = false; } [
      { sample = hm.sample; }
      os
    ]).sample
  );
in
assert os == { sample = ./discovery/sample/os/default.nix; };
assert
  hm == {
    sample = ./discovery/sample/hm/default.nix;
    unevaluated = ./discovery/unevaluated/hm/default.nix;
  };
assert result.config.sample == "discovered";
assert !collision.success;
runCommand "feature-module-discovery" { } "touch $out"
