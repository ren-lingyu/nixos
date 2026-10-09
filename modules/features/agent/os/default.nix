{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.modules.features.agent;

in
{

  config = lib.mkIf cfg.enable {

    environment.pathsToLink = [ "/share/skills" ];

  };

}
