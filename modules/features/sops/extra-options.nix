feature_ : { config, pkgs, lib, llib, ... } : {

  allowUsernameList = lib.mkOption {
    type = lib.types.unique {
      message = "Only one module may define `modules.features.${feature_}.allowUsernameList`.";
    } (lib.types.listOf lib.types.nonEmptyStr);
    default = [];
    internal = true;
    description = "Login names resolved from `allowUidList` for internal use by the SOPS feature.";
  };

  ageKeys = {
    hm = {
      name = lib.mkOption {
        type = lib.types.unique {
          message = ".";
        } lib.types.str;
        internal = true;
        description = ".";
      };
      path = lib.mkOption {
        type = lib.types.unique {
          message = ".";
        } lib.types.str;
        internal = true;
        description = ".";
      };
    };
  };

}
