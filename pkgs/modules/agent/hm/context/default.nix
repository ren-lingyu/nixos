{
  pkgs,
  lib,
  git,
  git-agent-workflow,
}:
(builtins.concatStringsSep "\n\n" [
  (builtins.readFile ./preamble.md)
  (builtins.readFile (
    pkgs.replaceVarsWith {
      src = ./runtime.md;
      replacements = {
        git = lib.getExe git;
        git-agent-workflow = lib.getExe git-agent-workflow;
        realpath = lib.getExe' pkgs.coreutils "realpath";
      };
    }
  ))
  (builtins.readFile ./gaw.md)
  (builtins.readFile ./policy.md)
])
