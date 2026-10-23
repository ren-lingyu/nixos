{
  pkgs,
  llib,
  rootPath,
}:
let
  args_ = {
    root = ./.;
    overlayFile = "test-overlay.nix";
    separator = "/";
  };
in
llib.tests.mkChecks {
  inherit (args_) root overlayFile separator;

  scope =
    (pkgs.lib.makeScope pkgs.newScope (_: {
      inherit pkgs llib rootPath;
    })).overrideScope
      (
        pkgs.lib.composeManyExtensions (
          builtins.attrValues (llib.tests.mkOverlays { inherit (args_) root overlayFile; })
        )
      );
}
