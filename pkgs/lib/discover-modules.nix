{ lib }:
{ root, modulePath }:
let
  entries = builtins.readDir root;
in
lib.mapAttrs (name: _: root + "/${name}/${modulePath}") (
  lib.filterAttrs (
    name: kind:
    let
      entry = root + "/${name}/${modulePath}";
    in
    kind == "directory"
    && builtins.pathExists entry
    && (builtins.readDir (dirOf entry)).${baseNameOf entry} == "regular"
  ) entries
)
