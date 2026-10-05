{
  pkgs,
  lib,
  git,
} : (builtins.concatStringsSep
  "\n\n"
  [
    (builtins.readFile ./preamble.md)
    (builtins.readFile (pkgs.replaceVarsWith {
      src = ./runtime.md;
      replacements = {
        git = lib.getExe git;
        realpath = lib.getExe' pkgs.coreutils "realpath";
      };
    }))
    (builtins.readFile ./policy.md)
  ]
)
