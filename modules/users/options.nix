{ lib, llib, ... }: {
  options.nixosBuilderArgs.userRegistry = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          identity = lib.mkOption {
            type = llib.types.identity;
            internal = true;
            readOnly = true;
            description = "Identity configuration for this User Profile.";
          };
          secrets = lib.mkOption {
            type = llib.secrets.declarationType;
            default = { };
            description = "Secret resources owned by this User Profile.";
          };
        };
      }
    );
  };
}
