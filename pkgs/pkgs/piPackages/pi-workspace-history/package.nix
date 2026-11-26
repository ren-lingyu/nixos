{
  lib,
  buildNpmPackage,
  importNpmLock,
  src,
  nodejs,
}:
(buildNpmPackage {
  inherit src nodejs;

  pname = "pi-workspace-history";
  version = (lib.importJSON "${src}/package.json").version;

  npmDeps = importNpmLock {
    npmRoot = "${src}";
    package = builtins.removeAttrs (lib.importJSON "${src}/package.json") [
      "devDependencies"
      "peerDependencies"
      "peerDependenciesMeta"
    ];
    packageLock =
      let
        lock = lib.importJSON "${src}/package-lock.json";
      in
      lock
      // {
        packages = lib.filterAttrs (name: entry: name == "" || !(entry.dev or false)) lock.packages // {
          "" = builtins.removeAttrs lock.packages."" [
            "devDependencies"
            "peerDependencies"
            "peerDependenciesMeta"
          ];
        };
      };
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  npmInstallFlags = [
    "--omit=dev"
    "--omit=peer"
  ];

  dontNpmBuild = true;

  installPhase = builtins.concatStringsSep "\n" [
    "runHook preInstall"
    ""
    "npm pack --ignore-scripts --pack-destination \"$TMPDIR\""
    "mkdir -p \"$out\""
    "tar -xzf \"$TMPDIR/$pname-$version.tgz\" --strip-components=1 -C \"$out\""
    "rm -f node_modules/.package-lock.json"
    "cp -r node_modules \"$out\""
    ""
    "runHook postInstall"
  ];

  doInstallCheck = true;
  installCheckPhase = builtins.concatStringsSep "\n" [
    "runHook preInstallCheck"
    "test -f \"$out/package.json\""
    "test -f \"$out/.pi/extensions/workspace-history.ts\""
    "test -f \"$out/node_modules/ignore/package.json\""
    "test ! -e \"$out/node_modules/@earendil-works/pi-coding-agent\""
    "runHook postInstallCheck"
  ];

  meta = {
    description = "Real workspace undo/redo for Pi";
    homepage = "https://github.com/wcldyx/pi-workspace-history";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
