feature_ : { config, pkgs, lib, ... } : {
  
  session-wrapper = lib.mkOption {
    type = lib.types.unique {
      message = "Only one module may define `modules.features.${feature_}.session-wrapper`.";
    } (lib.types.nullOr lib.types.package);
    default = null;
    internal = true;
    description = "Internal package providing the X11 session command for greeters.";
  };
  
}
