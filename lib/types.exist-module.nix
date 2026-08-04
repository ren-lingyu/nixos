{ lib } : { optionPath } : lib.types.submodule {

  options = {

    os = lib.mkOption {
      type = lib.types.unique {
        message = "Only one module may define `${optionPath}.os`.";
      } (lib.types.nullOr lib.types.bool);
      default = null;
      example = true;
      description = "Whether the OS module exists.";
    };

    hm = lib.mkOption {
      type = lib.types.unique {
        message = "Only one module may define `${optionPath}.hm`.";
      } (lib.types.nullOr lib.types.bool);
      default = null;
      example = true;
      description = "Whether the Home Manager module exists.";
    };

  };

}
