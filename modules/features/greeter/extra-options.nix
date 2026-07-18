feature_ : { config, pkgs, lib, ... } : {

  sessionPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    description = "";
  };

  monitor = lib.mkOption {
    type = lib.types.unique {
      message = "`modules.features.greater.monitor`";
    } (lib.types.submodule ({ name, config, ... } : {
      options = {
        name = lib.mkOption {
          type =  lib.types.nullOr lib.types.str;
          default = null;
          example = "eDP-1";
          description = "Name of the default monitor.";
        };
      };
    }));
    internal = true;
    default = { };
    example = {
      name = "eDP-1";
    };
    description = "Metadata of the default monitor.";
  };

}
