{ lib, ... }: {
  options.secrets = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    readOnly = true;
    description = "Tree of selected Account secrets; each leaf exposes only its OS agenix runtime path.";
  };
}
