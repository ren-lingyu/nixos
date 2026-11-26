{
  lib,
  buildNpmPackage,
  importNpmLock,
  src,
  nodejs,
  makeWrapper,
  git,
  ripgrep,
}:
(buildNpmPackage (finalAttrs_: {
  inherit src nodejs;

  pname = "pi-agentic-search";
  version = (lib.importJSON "${src}/package.json").version;

  npmDeps = importNpmLock { npmRoot = "${src}"; };
  npmConfigHook = importNpmLock.npmConfigHook;

  npmInstallFlags = [ "--omit=peer" ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = builtins.concatStringsSep "\n" [
    "runHook preInstall"
    ""
    # Pack the built project using its original upstream package manifest.
    "npm pack --ignore-scripts --pack-destination \"$TMPDIR\""
    "mkdir -p \"$out\""
    "tar -xzf \"$TMPDIR/$pname-$version.tgz\" --strip-components=1 -C \"$out\""
    ""
    # Use the local tarball references again while pruning offline.
    "cp --no-preserve=mode ${finalAttrs_.npmDeps}/package.json package.json"
    "cp --no-preserve=mode ${finalAttrs_.npmDeps}/package-lock.json package-lock.json"
    "npm prune --offline --omit=dev --omit=peer --ignore-scripts --no-save"
    "rm -f node_modules/.package-lock.json"
    "cp -r node_modules \"$out\""
    ""
    "makeWrapper ${lib.getExe' nodejs "node"} \"$out/bin/agentic-search\" --add-flags \"$out/bin/agentic-search.mjs\" --prefix PATH : ${
      lib.makeBinPath [
        git
        ripgrep
      ]
    }"
    ""
    "runHook postInstall"
  ];

  doInstallCheck = true;
  installCheckPhase = builtins.concatStringsSep "\n" [
    "runHook preInstallCheck"
    "test -f \"$out/package.json\""
    "test -f \"$out/index.ts\""
    "test -f \"$out/skills/agentic-search/SKILL.md\""
    "test ! -e \"$out/node_modules/@earendil-works/pi-coding-agent\""
    "\"$out/bin/agentic-search\" --help > /dev/null"
    "runHook postInstallCheck"
  ];

  meta = {
    description = "Pi extension for agent-oriented ranked code search and one-call diff context packs";
    homepage = "https://github.com/dantetekanem/pi-agentic-search";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "agentic-search";
  };
}))
