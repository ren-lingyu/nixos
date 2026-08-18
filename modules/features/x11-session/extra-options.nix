feature_ : { config, pkgs, lib, llib, ... } : {

  session-wrapper = lib.mkOption {
    type = lib.types.nullOr lib.types.package;
    internal = true;
    readOnly = true;
    description = "Internal package providing the X11 session command for greeters.";
  };

}
