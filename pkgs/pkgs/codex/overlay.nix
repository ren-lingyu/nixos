{ }:
final_: prev_:
let
  inherit (final_)
    lib
    symlinkJoin
    makeWrapper
    python3
    bubblewrap
    ;
  inherit (prev_) codex;
in
{
  codex = symlinkJoin {

    name = codex.name;

    paths = [ codex ];

    nativeBuildInputs = [ makeWrapper ];

    postBuild = builtins.concatStringsSep "\n" [
      "wrapProgram \"$out/bin/codex\" --prefix PATH : ${
        lib.makeBinPath [
          (python3.withPackages (pythonPackages_: [
            pythonPackages_.pyyaml
          ]))
          bubblewrap
        ]
      }"
    ];

    meta = codex.meta;

  };
}
