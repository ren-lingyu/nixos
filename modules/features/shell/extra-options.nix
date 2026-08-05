feature_ : { config, pkgs, lib, llib, ... } : {

  zsh = {
    package = lib.mkOption {
      type = lib.types.unique {
        message = "Conflicting definitions for `modules.features.${feature_}.zsh.package`.";
      } lib.types.package;
      internal = true;
      default = pkgs.zsh;
      example = lib.literalExpression "pkgs.zsh";
      description = "Zsh package shared by the NixOS and Home Manager shell configurations.";
    };
  };

  bash = {
    package = lib.mkOption {
      type = lib.types.unique {
        message = "Conflicting definitions for `modules.features.${feature_}.bash.package`.";
      } lib.types.package;
      internal = true;
      default = pkgs.bash;
      example = lib.literalExpression "pkgs.bashInteractive";
      description = "Bash package shared by the NixOS and Home Manager shell configurations.";
    };
  };

}
