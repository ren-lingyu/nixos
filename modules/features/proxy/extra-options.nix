feature_ : { config, pkgs, lib, ... } : {

  clash-verge.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable clash-verge.";
  };

  throne.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable the throne.";
  };

  mihomo.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable the mihomo service.";
  };

  v2raya.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable the v2raya service.";
  };

}
