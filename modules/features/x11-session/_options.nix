{ lib, llib, ... }: {

  session-wrapper = lib.mkOption {
    type = lib.types.functionTo (lib.types.nullOr lib.types.package);
    default = _: null;
    internal = true;
    readOnly = true;
    description = "Internal package providing the X11 session command for greeters.";
  };

}
