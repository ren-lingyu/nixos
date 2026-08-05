feature_ : { config, pkgs, lib, llib, ... } : {

  zsh = {
    package = lib.mkOption {
      type = lib.types.unique {
        message = "";
      } lib.types.package;
      internal = true;
      default = pkgs.zsh;
      description = "";
    };
  };

  bash = {
    package = lib.mkOption {
      type = lib.types.unique {
        message = "";
      } lib.types.package;
      internal = true;
      default = pkgs.bash;
      description = "";
    };
  };

}
