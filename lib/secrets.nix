{ lib }:
let
  mkTreeType =
    marker: leafOption:
    lib.types.attrsOf (
      lib.fix (
        self:
        lib.types.mkOptionType {
          name = "secretTreeNode";
          description = "a secret leaf or a nested attribute set of secrets";
          check = builtins.isAttrs;
          merge =
            loc: defs:
            assert lib.assertMsg (
              builtins.match "[A-Za-z0-9_-]+" (lib.last loc) != null
              && !(builtins.elem (lib.last loc) [
                "rekeyFile"
                "enable"
              ])
            ) "Invalid secret path component in `${lib.showOption loc}`.";
            if builtins.any (def: builtins.hasAttr marker def.value) defs then
              assert lib.assertMsg (builtins.all (
                def: builtins.all (key: key == marker) (builtins.attrNames def.value)
              ) defs) "Secret leaf `${lib.showOption loc}` cannot also contain branches.";
              (lib.types.submodule { options.${marker} = leafOption; }).merge loc defs
            else
              (lib.types.attrsOf self).merge loc defs;
        }
      )
    );
in
{
  userSecretName = uid: path: "secrets.user.${toString uid}.${lib.concatStringsSep "." path}";

  declarationType = mkTreeType "rekeyFile" (
    lib.mkOption {
      type = lib.types.path;
      description = "Repository ciphertext to rekey for the Host.";
    }
  );

  selectionType = mkTreeType "enable" (lib.mkEnableOption "delivery of this secret to the Account");

  # An omitted leaf is disabled. Validate all explicitly selected paths, even
  # disabled ones, and remove empty branches from the resulting resource tree.
  selectTree =
    declarations: selections:
    let
      walk =
        prefix: declared: selected:
        lib.filterAttrs (_: node: node != { }) (
          lib.mapAttrs (
            name: node:
            let
              path = prefix ++ [ name ];
              resource = declared.${name};
            in
            assert lib.assertMsg (builtins.hasAttr name declared)
              "Unknown User secret `${lib.showOption path}`.";
            if resource ? rekeyFile then
              assert lib.assertMsg (
                node ? enable || node == { }
              ) "User secret `${lib.showOption path}` is a leaf.";
              if node.enable or false then resource else { }
            else
              assert lib.assertMsg (
                !(node ? enable)
              ) "User secret `${lib.showOption path}` is a branch; select individual leaves.";
              walk path resource node
          ) selected
        );
    in
    walk [ ] declarations selections;

  flattenTree =
    let
      walk =
        prefix: tree:
        lib.concatLists (
          lib.mapAttrsToList (
            name: node:
            if node ? rekeyFile then
              [
                {
                  path = prefix ++ [ name ];
                  inherit (node) rekeyFile;
                }
              ]
            else
              walk (prefix ++ [ name ]) node
          ) tree
        );
    in
    walk [ ];
}
