feature_ : { config, pkgs, lib, llib, ... } : {

  allowUsernameList = lib.mkOption {
    type = lib.types.listOf lib.types.nonEmptyStr;
    internal = true;
    readOnly = true;
    description = "Login names resolved from `allowUidList` for internal use by the SOPS feature.";
  };

  ageKeys = {
    hm = {
      name = lib.mkOption {
        type = lib.types.str;
        internal = true;
        readOnly = true;
        description = ".";
      };
      path = lib.mkOption {
        type = lib.types.str;
        internal = true;
        readOnly = true;
        description = ".";
      };
    };
  };

}
