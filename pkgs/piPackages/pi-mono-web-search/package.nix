{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
} : (stdenvNoCC.mkDerivation
  (finalAttrs_ : {

    pname = "pi-mono-web-search";
    version = "0.1.0";

    src = fetchFromGitHub {
      owner = "emanuelcasco";
      repo = "pi-mono-extensions";
      rev = "e4e047a5a203cac78f5e420c92a3115ccd2fe6bb";
      hash = "sha256-vPLPA3/tHmM+rcHyLeVsotjr8yD0B+a3S5ph05owjWo=";
    };

    pnpmWorkspaces = [
      "pi-common"
      "pi-mono-web-search"
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs_)
        pname
        version
        src
        pnpmWorkspaces
        ;
      pnpm = pnpm_10;
      fetcherVersion = 4;
      hash = "sha256-lz5tOO637ivyzvlv1dks3K5Gq46CZ/ZCl0Cyr4IDxXU=";
    };

    nativeBuildInputs = [
      nodejs
      pnpm_10
      pnpmConfigHook
    ];

    dontBuild = true;

    installPhase = builtins.concatStringsSep "\n" [
      (lib.escapeShellArgs [ "runHook" "preInstall" ])
      ""
      (lib.escapeShellArgs [
        "pnpm"
        "config"
        "set"
        "--location=project"
        "inject-workspace-packages"
        "true"
      ])
      ""
      (lib.escapeShellArgs [
        "pnpm"
        "--filter=pi-mono-web-search"
        "--prod"
        "deploy"
        (builtins.placeholder "out")
      ])
      ""
      (lib.escapeShellArgs [ "runHook" "postInstall" ])
      ""
    ];

    meta = {
      description = "Pi extension for web search and page reading using DuckDuckGo and readability extraction";
      homepage = "https://github.com/emanuelcasco/pi-mono-extensions";
      platforms = lib.platforms.all;
    };

  })
)
