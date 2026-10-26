{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  python3,
  writeShellScript,
}:
(stdenvNoCC.mkDerivation (finalAttrs_: {
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

  # Run from the repository root. This package has tags without GitHub releases.
  passthru.updateScript = writeShellScript "update-pi-mono-context" ''
    set -eu
    updated=$(${lib.getExe python3} - <<'PY'
    import json
    from pathlib import Path
    import re
    import urllib.request

    url = "https://api.github.com/repos/emanuelcasco/pi-mono-extensions/git/matching-refs/tags/pi-mono-context@"
    with urllib.request.urlopen(url, timeout=30) as response:
        refs = json.load(response)
    versions = []
    for ref in refs:
        match = re.fullmatch(r"refs/tags/pi-mono-context@([0-9]+\.[0-9]+\.[0-9]+)", ref["ref"])
        if match:
            versions.append((tuple(map(int, match[1].split("."))), match[1]))
    if not versions:
        raise SystemExit("No stable pi-mono-context tag found")
    candidate, version = max(versions)
    if candidate <= tuple(map(int, "${finalAttrs_.version}".split("."))):
        raise SystemExit(0)
    path = Path("pkgs/pkgs/piPackages/pi-mono-context/package.nix")
    source = path.read_text()
    source, versions_changed = re.subn(
        r'(?m)^  version = "' + re.escape("${finalAttrs_.version}") + r'";$',
        f'  version = "{version}";', source,
    )
    source, revisions_changed = re.subn(
        r'(?m)^    rev = "' + re.escape("${finalAttrs_.src.rev}") + r'";$',
        f'    rev = "pi-mono-context@{version}";', source,
    )
    if versions_changed != 1 or revisions_changed != 1:
        raise SystemExit("Recipe differs from the evaluated package; refusing to edit")
    path.write_text(source)
    print(version)
    PY
    )
    if [ -z "$updated" ]; then
      echo "No newer pi-mono-context tag; keeping the current snapshot."
      exit 0
    fi
    exec ${
      lib.escapeShellArgs (nix-update-script {
        attrPath = "legacyPackages.${stdenvNoCC.hostPlatform.system}.piPackages.pi-mono-context";
        extraArgs = [
          "--flake"
          "--version=skip"
        ];
      })
    }
  '';

  meta = {
    description = "Pi extension that prints current context-window usage without adding the report to future LLM context";
    homepage = "https://github.com/emanuelcasco/pi-mono-extensions";
    platforms = lib.platforms.all;
  };
}))
