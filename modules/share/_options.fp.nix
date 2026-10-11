{
  lib,
  llib,
  path,
  ...
}:
{
  configuration = {
    allowUnfreePredicateList = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "github-copilot-cli" ];
      description = "Package names allowed by the global unfree package predicate.";
    };

    createXdgUserDirectories = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable and create XDG user directories.";
    };
  };
  metadata = { };
}
