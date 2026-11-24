{ config, lib, ... }: {
  options.features.agent.enable = lib.mkEnableOption "system agent tools";

  config = lib.mkIf config.features.agent.enable { environment.pathsToLink = [ "/share/skills" ]; };
}
