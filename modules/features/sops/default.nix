{ lib, ... }: {
  options = {
    nixosConfigurations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, ... }: {
            config = {
              features.sops.module.features.sops.authorizedUids = lib.mapAttrsToList (
                uid: _: builtins.fromJSON uid
              ) (lib.filterAttrs (_: account: account.features.sops.enable) config.users);
            };
          }
        )
      );
    };
  };

  config = {
    nixosBuilderArgs.featureRegistry = {
      os.sops = ./os;
      hm.sops = ./hm;
    };
  };
}
