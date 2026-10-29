{
  lib,
  stdenvNoCC,
  installAgentSkills,
  fetchFromGitHub,
}:
let
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
in
stdenvNoCC.mkDerivation (finalAttrs_: {
  pname = "git-maintenance";
  version = "0.0.0";

  src = ./src;

  nativeBuildInputs = [ installAgentSkills ];

  dontConfigure = true;
  dontBuild = true;

  postPatch = lib.concatLines (
    builtins.map (
      standardFile_:
      "install -Dm644 ${
        lib.escapeShellArgs [
          standardFile_.src
          "git-maintenance/${standardFile_.path}"
        ]
      }"
    ) standardFiles
  );

  doInstallCheck = true;

  installCheckPhase =
    let
      checkFile = src_: path_: [
        ''test -s "$installedSkills/${path_}"''
        ''cmp ${lib.escapeShellArg src_} "$installedSkills/${path_}"''
      ];
    in
    lib.concatLines (
      builtins.concatLists [
        [
          "runHook preInstallCheck"
          ''installedSkills="$out/share/skills/git-maintenance"''
        ]
        (lib.concatMap
          (file_: checkFile "${file_}" (lib.removePrefix "${toString finalAttrs_.src}/" (toString file_)))
          (
            lib.filter (file_: lib.hasSuffix ".md" (toString file_)) (
              lib.filesystem.listFilesRecursive finalAttrs_.src
            )
          )
        )
        (lib.concatMap (
          standardFile_: checkFile standardFile_.src "git-maintenance/${standardFile_.path}"
        ) standardFiles)
        [ "runHook postInstallCheck" ]
      ]
    );

  meta = {
    description = "Repository-generic Git maintenance skill for coding agents";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
