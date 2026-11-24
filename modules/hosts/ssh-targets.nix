{
  config,
  lib,
  llib,
  ...
}:
let
  enabledHost_ = llib.hosts.getUniqueEnabledHost config.modules.hosts;

  sshTargets_ = llib.hosts.mkWireGuardSshTargets {
    registry = config.modules.hosts;
    topology = config.networking.wireguard.topology;
    baseOrder = 1000;
  };
in
{
  config.programs.ssh = lib.mkIf (enabledHost_.wireguard != null) {
    hosts = sshTargets_.hosts;
    knownHosts = sshTargets_.knownHosts;
  };
}
