{ lib }: {
  userSecretName = uid: path: "secrets.user.${toString uid}.${lib.concatStringsSep "." path}";

  # The option path passed to merge includes the HM submodule's prefix.
  # Only the caller knows where its secrets tree starts.
  mkTreeType =
    pathFor:
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
              builtins.match "[A-Za-z0-9_-]+" (lib.last loc) != null && lib.last loc != "rekeyFile"
            ) "Invalid secret path component in `${lib.showOption loc}`.";
            if builtins.any (def: def.value ? rekeyFile) defs then
              assert lib.assertMsg (builtins.all (
                def:
                builtins.all (
                  key:
                  builtins.elem key [
                    "rekeyFile"
                    "path"
                  ]
                ) (builtins.attrNames def.value)
              ) defs) "Secret leaf `${lib.showOption loc}` cannot also contain branches.";
              (lib.types.submodule {
                options = {
                  rekeyFile = lib.mkOption {
                    type = lib.types.path;
                    description = "Repository ciphertext to rekey for the Host.";
                  };
                  path = lib.mkOption {
                    type = lib.types.str;
                    readOnly = true;
                    default = pathFor loc;
                    description = "Runtime path supplied by OS agenix.";
                  };
                };
              }).merge
                loc
                defs
            else
              (lib.types.attrsOf self).merge loc defs;
        }
      )
    );

  # Read only the declaration, never the derived path back into OS config.
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
