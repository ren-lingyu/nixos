{ lib }: rec {
  monitor = import ./monitor-type.nix { inherit lib; };
  monitors = lib.types.attrsOf monitor;

  defaultEditor = lib.types.nullOr (
    lib.types.enum [
      "vim"
      "neovim"
      "emacs"
    ]
  );

  sopsSecretsInput = lib.types.listOf (
    lib.types.submodule {
      options = {
        template = lib.mkOption {
          type = lib.types.enum [ "user" ];
          default = "user";
          description = "Secret template used to generate paths and ownership for this Home Manager user.";
        };
        structure = lib.mkOption {
          type = lib.types.attrsOf (
            lib.fix (
              self:
              lib.mergeAttrsList [
                (lib.types.either (lib.types.nonEmptyListOf lib.types.nonEmptyStr) (lib.types.attrsOf self))
                { description = "a non-empty list of strings or a nested attribute set"; }
              ]
            )
          );
          default = { };
          description = "Nested secret-key structure converted into individual sops-nix secret declarations.";
        };
      };
    }
  );
}
