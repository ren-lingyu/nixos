{
  lib,
  buildNpmPackage,
  src,
  fetchNpmDeps,
  jq,
  nodejs_22,
  replaceVarsWith,
}:
let

  postPatch_ = builtins.readFile (replaceVarsWith {
    src = ./fetch-npm-deps-post-patch.sh;
    replacements = {
      jq = lib.getExe jq;
    };
  });

in
(buildNpmPackage (finalAttrs_: {
  inherit src;

  pname = "pi-workspace-history";
  version = (builtins.fromJSON (builtins.readFile "${src}/package.json")).version;

  nodejs = nodejs_22;

  postPatch = postPatch_;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs_) src;

    hash = "sha256-5qkoYPFYYodiYe+V2IDKUFdSF0W8Fftmt1q1SeBgLzg=";

    postPatch = postPatch_;
  };

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
      "${builtins.placeholder "out"}/.pi"
    ])
    ""
    (lib.escapeShellArgs [
      "cp"
      "-r"
      ".pi/extensions"
      "${builtins.placeholder "out"}/.pi/"
    ])
    ""
    (lib.escapeShellArgs [
      "cp"
      "package.json"
      "README.md"
      "README.zh-CN.md"
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
    description = "Real workspace undo/redo for Pi";
    homepage = "https://github.com/wcldyx/pi-workspace-history";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}))
