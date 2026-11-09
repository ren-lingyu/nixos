{
  lib,
  buildNpmPackage,
  src,
  nodejs_22,
}:
(buildNpmPackage (unused_finalAttrs_: {
  inherit src;

  pname = "pi-agentic-search";
  version = (builtins.fromJSON (builtins.readFile "${src}/package.json")).version;

  nodejs = nodejs_22;

  npmDepsHash = "sha256-adBodkfvix1/fpMTxZ10zmdjEAaR6UYvTAdctqRtfHY=";

  npmInstallFlags = [
    "--omit=dev"
    "--omit=peer"
  ];

  dontNpmBuild = true;

  installPhase = builtins.concatStringsSep "\n" [
    (lib.escapeShellArgs [
      "runHook"
      "preInstall"
    ])
    ""
    (lib.escapeShellArgs [
      "mkdir"
      "-p"
      (builtins.placeholder "out")
    ])
    ""
    (lib.escapeShellArgs [
      "cp"
      "-r"
      "package.json"
      "index.ts"
      "src"
      "README.md"
      "CHANGELOG.md"
      "LICENSE"
      "SECURITY.md"
      "docs"
      (builtins.placeholder "out")
    ])
    ""
    (lib.escapeShellArgs [
      "cp"
      "-r"
      "node_modules"
      (builtins.placeholder "out")
    ])
    ""
    (lib.escapeShellArgs [
      "runHook"
      "postInstall"
    ])
    ""
  ];

  meta = {
    description = "Pi extension for agent-oriented ranked code search and one-call diff context packs";
    homepage = "https://github.com/dantetekanem/pi-agentic-search";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}))
