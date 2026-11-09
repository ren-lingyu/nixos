{
  lib,
  stdenvNoCC,
  src,
}:
(stdenvNoCC.mkDerivation {
  inherit src;

  pname = "pi-mono-context";
  version = (builtins.fromJSON (builtins.readFile "${src}/extensions/context/package.json")).version;

  dontBuild = true;

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
    (lib.escapeShellArgs [
      "cp"
      "-r"
      "extensions/context/."
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
    description = "Pi extension that prints current context-window usage without adding the report to future LLM context";
    homepage = "https://github.com/emanuelcasco/pi-mono-extensions";
    platforms = lib.platforms.all;
  };
})
