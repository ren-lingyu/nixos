{
  config,
  host,
  hostRegistry,
  llib,
  ...
}:
let
  sshTargets_ = llib.hosts.mkSshTargets {
    registry = hostRegistry;
    topology = if host.wireguard == null then { } else config.networking.wireguard.topology;
    baseOrder = 1000;
  };
in
{
  config.programs.ssh = {
    hosts = sshTargets_.hosts;
    knownHosts = sshTargets_.knownHosts;
  };
}
