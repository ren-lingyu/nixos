{
  config,
  host,
  hostRegistry,
  lib,
  llib,
  ...
}:
let
  sshTargets_ = llib.hosts.mkWireGuardSshTargets {
    registry = hostRegistry;
    topology = config.networking.wireguard.topology;
    baseOrder = 1000;
  };
in
{
  config.programs.ssh = lib.mkIf (host.wireguard != null) {
    hosts = sshTargets_.hosts;
    knownHosts = sshTargets_.knownHosts;
  };
}
