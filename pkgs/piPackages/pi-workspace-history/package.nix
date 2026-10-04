{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  jq,
  nodejs_22,
  replaceVarsWith,
} : let

  postPatch_ = builtins.readFile (replaceVarsWith {
    src = ./fetch-npm-deps-post-patch.sh;
    replacements = {
      jq = lib.getExe jq;
    };
  });

in (buildNpmPackage
  (finalAttrs_ : {

    pname = "pi-workspace-history";
    version = "0.4.8";

    src = fetchFromGitHub {
      owner = "wcldyx";
      repo = "pi-workspace-history";
      rev = "4c51d3cad723bd8733c73fb36f4b971efb2eb53a";
      hash = "sha256-1sy/2t1aD6B3iTTNNUTrSzsxxfPuqTtQekXv/U5FECE=";
    };

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
      (lib.escapeShellArgs [ "runHook" "preInstall" ])
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
      (lib.escapeShellArgs [ "runHook" "postInstall" ])
      ""
    ];

    meta = {
      description = "Real workspace undo/redo for Pi";
      homepage = "https://github.com/wcldyx/pi-workspace-history";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };

  })
)
