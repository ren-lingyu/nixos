{
  lib,
  haskell,
  haskellPackages,
  emacs-nox,
  emacsPackagesFor,
  fetchFromGitHub,
  git,
  gh,
  installAgentSkills,
}:
let
  emacs = (emacsPackagesFor emacs-nox).emacsWithPackages (epkgs: [ epkgs.ox-gfm ]);
  skillSource = ./skill/git-maintenance;
  standardFiles =
    let
      keepAChangelogSrc_ = fetchFromGitHub {
        owner = "olivierlacan";
        repo = "keep-a-changelog";
        rev = "5417981223f2e87fb2c94e9c57a6c0b011447306";
        hash = "sha256-qES57L453dhTH4mwVO7o11tuMcUWq/SCF+Qakyqlf5c=";
      };
      semverSrc_ = fetchFromGitHub {
        owner = "semver";
        repo = "semver.org";
        rev = "839c747aeb15078beea00dbe93a84f2c0fd39878";
        hash = "sha256-/X9vGVHF4ZduzgCF1A/F7nW7s9S6i6wsYLhsmeFZNBM=";
      };
    in
    [
      {
        src = "${keepAChangelogSrc_}/source/en/2.0.0/index.html.md";
        path = "references/standards/keep-a-changelog/2.0.0.md";
      }
      {
        src = "${keepAChangelogSrc_}/LICENSE";
        path = "references/standards/keep-a-changelog/LICENSE";
      }
      {
        src = "${semverSrc_}/spec/v2.0.0.md";
        path = "references/standards/semver/2.0.0.md";
      }
    ];
  package_ = haskell.lib.dontHaddock (haskellPackages.callCabal2nix "git-maintenance" ./cabal { });
in
package_.overrideAttrs (old_: {
  GIT = lib.getExe git;
  GH = lib.getExe gh;
  EMACS = lib.getExe' emacs "emacs";

  nativeBuildInputs = (old_.nativeBuildInputs or [ ]) ++ [ installAgentSkills ];
  nativeCheckInputs = (old_.nativeCheckInputs or [ ]) ++ [ emacs ];

  postPatch = lib.concatLines (
    [
      (old_.postPatch or "")
      "cp -R ${skillSource} git-maintenance"
      "chmod -R u+w git-maintenance"
    ]
    ++ builtins.map (
      standardFile_:
      "install -Dm644 ${
        lib.escapeShellArgs [
          standardFile_.src
          "git-maintenance/${standardFile_.path}"
        ]
      }"
    ) standardFiles
  );

  meta = lib.mergeAttrsList [
    (old_.meta or { })
    {
      description = "Git maintenance skill and git-gm release CLI";
      license = with lib.licenses; [
        mit
        cc-by-30
      ];
      platforms = lib.platforms.unix;
    }
  ];
})
