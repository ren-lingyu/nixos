{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
} : (stdenvNoCC.mkDerivation
  (unused_finalAttrs_ : {

    pname = "pi-mono-context";
    version = "0.1.1";

    src = fetchFromGitHub {
      owner = "emanuelcasco";
      repo = "pi-mono-extensions";
      rev = "e4e047a5a203cac78f5e420c92a3115ccd2fe6bb";
      hash = "sha256-vPLPA3/tHmM+rcHyLeVsotjr8yD0B+a3S5ph05owjWo=";
    };

    dontBuild = true;

    installPhase = builtins.concatStringsSep "\n" [
      (lib.escapeShellArgs [ "runHook" "preInstall" ])
      ""
      (lib.escapeShellArgs [
        "mkdir"
        "-p"
        (builtins.placeholder "out")
      ])
      (lib.escapeShellArgs [
        "cp"
        "-r"
        "extensions/context/."
        (builtins.placeholder "out")
      ])
      ""
      (lib.escapeShellArgs [ "runHook" "postInstall" ])
      ""
    ];

    meta = {
      description = "Pi extension that prints current context-window usage without adding the report to future LLM context";
      homepage = "https://github.com/emanuelcasco/pi-mono-extensions";
      platforms = lib.platforms.all;
    };

  })
)
