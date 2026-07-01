feature_ : { config, pkgs, lib, ... } : {

  sessionPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    description = "";
  };
  
  monitor = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
      example = "eDP-1";
      description = "Name of the primary monitor.";
    };
    width = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 3072;
      example = 3072;
      description = "Width of the primary monitor in pixels.";
    };
    height = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 1920;
      example = 1920;
      description = "Height of the primary monitor in pixels.";
    };
  };
  
}
