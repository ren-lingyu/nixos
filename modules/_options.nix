{
  lib,
  llib,
  path,
  ...
}:
{
  configuration = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable this module.";
    };
  };

  metadata = {
    existModule = lib.mkOption {
      type = llib.types.existModule {
        optionPath = "${llib.moduleFunctions.default.mkOptionName path}.existModule";
      };
      internal = true;
      default = { };
      description = "Availability of the OS and Home Manager implementations.";
    };
  };
}
