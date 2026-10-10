{ lib, llib, ... }: {

  zsh = {
    package = lib.mkOption {
      type = lib.types.functionTo lib.types.package;
      internal = true;
      readOnly = true;
      example = lib.literalExpression "{ pkgs, ... }: pkgs.zsh";
      description = "Zsh package shared by the NixOS and Home Manager shell configurations.";
    };
  };

  bash = {
    package = lib.mkOption {
      type = lib.types.functionTo lib.types.package;
      internal = true;
      readOnly = true;
      example = lib.literalExpression "{ pkgs, ... }: pkgs.bashInteractive";
      description = "Bash package shared by the NixOS and Home Manager shell configurations.";
    };
  };

}
