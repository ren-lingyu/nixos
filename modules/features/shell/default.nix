{
  config,
  lib,
  pkgs,
  ...
}:
{

  config = {
    moduleInternals.features.shell = {

      zsh = {
        package = pkgs.zsh;
      };
      bash = {
        package = pkgs.bashInteractive;
      };
    };
  };

}
