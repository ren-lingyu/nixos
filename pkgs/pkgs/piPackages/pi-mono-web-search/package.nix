{
  lib,
  stdenvNoCC,
  src,
  fetchPnpmDeps,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
}:
(stdenvNoCC.mkDerivation (finalAttrs_: {
  inherit src;

  pname = "pi-mono-web-search";
  version =
    (builtins.fromJSON (builtins.readFile "${src}/extensions/web-search/package.json")).version;

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
    (lib.escapeShellArgs [
      "runHook"
      "preInstall"
    ])
    ""
    (lib.escapeShellArgs [
      "patch"
      "-p1"
      "-i"
      "${./disable-auto-install-peers.patch}"
    ])
    ""
    (lib.escapeShellArgs [
      "pnpm"
      "config"
      "set"
      "--location=project"
      "auto-install-peers"
      "false"
    ])
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
    (lib.escapeShellArgs [
      "runHook"
      "postInstall"
    ])
    ""
  ];

  doInstallCheck = true;

  installCheckPhase = builtins.concatStringsSep "\n" [
    (lib.escapeShellArgs [
      "runHook"
      "preInstallCheck"
    ])
    ""
    (lib.escapeShellArgs [
      (lib.getExe' nodejs "node")
      "${./install-check.mjs}"
      (builtins.placeholder "out")
    ])
    ""
    (lib.escapeShellArgs [
      "runHook"
      "postInstallCheck"
    ])
    ""
  ];

  meta = {
    description = "Pi extension for web search and page reading using DuckDuckGo and readability extraction";
    homepage = "https://github.com/emanuelcasco/pi-mono-extensions";
    platforms = lib.platforms.all;
  };
}))
