feature_ : { config, pkgs, lib, llib, ... } : {

  sessionPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    internal = true;
    readOnly = true;
    description = "Internal session packages provided to the greeter.";
  };

  monitor = lib.mkOption {
    type = lib.types.submodule ({ name, config, ... } : {
      options = {
        name = lib.mkOption {
          type =  lib.types.nullOr lib.types.str;
          default = null;
          example = "eDP-1";
          description = "Name of the default monitor.";
        };
      };
    });
    internal = true;
    readOnly = true;
    example = {
      name = "eDP-1";
    };
    description = "Metadata of the default monitor.";
  };

}
