{
  lib,
  haskell,
  haskellPackages,
  emacs-nox,
  emacsPackagesFor,
  git,
  gh,
  installAgentSkills,
  keep-a-changelog,
  semver-org,
}:
let
  emacs = (emacsPackagesFor emacs-nox).emacsWithPackages (epkgs: [ epkgs.ox-gfm ]);
  skillSource = ./skill/git-maintenance;
  standardFiles = [
    {
      src = "${keep-a-changelog}/source/en/2.0.0/index.html.md";
      path = "references/standards/keep-a-changelog/2.0.0.md";
    }
    {
      src = "${keep-a-changelog}/LICENSE";
      path = "references/standards/keep-a-changelog/LICENSE";
    }
    {
      src = "${semver-org}/spec/v2.0.0.md";
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
