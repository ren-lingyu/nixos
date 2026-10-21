{ path }: {
  metadata =
    { lib, registry, ... }:
    let
      hosts = registry.hosts;
      numbers = builtins.map (host: host.metadata.number) (builtins.attrValues hosts);
    in
    assert lib.assertMsg (
      builtins.length numbers == builtins.length (lib.unique numbers)
    ) "Host numbers must be globally unique.";
    builtins.all (valid: valid) (
      lib.mapAttrsToList (
        hostName: host:
        let
          metadata = host.metadata;
          monitors = builtins.attrValues metadata.monitors;
          names = builtins.map (monitor: monitor.name) monitors;
          wg = metadata.wireguard;
        in
        assert lib.assertMsg (
          lib.count (monitor: monitor.role == "default") monitors <= 1
        ) "At most one monitor in Host `${hostName}` may have role = default.";
        assert lib.assertMsg (
          builtins.length names == builtins.length (lib.unique names)
        ) "Monitor names in Host `${hostName}` must be unique.";
        assert lib.assertMsg (builtins.all (
          monitor: monitor.role != "default" || monitor.mode != null
        ) monitors) "Default monitors in Host `${hostName}` must provide a non-null mode.";
        assert lib.assertMsg (builtins.all (valid: valid)
          (
            lib.mapAttrsToList (
              key: uid: builtins.match "^[0-9]+$" key != null && key == builtins.toString uid
            ) metadata.users
          )
        ) "Host `${hostName}` UID registry keys must be canonical decimal representations of their values.";
        lib.assertMsg (
          wg == null || wg.endpoint == null || wg.listenPort != null
        ) "Host `${hostName}` with a WireGuard endpoint must provide wireguard.listenPort."
      ) hosts
    );

  configuration =
    {
      lib,
      name,
      configuration,
      ...
    }:
    let
      enabled = builtins.attrNames (lib.filterAttrs (_: host: host.enable) configuration.modules.hosts);
    in
    lib.assertMsg (builtins.length enabled == 1)
      "System `${name}` requires exactly one enabled Host; enabled Hosts: ${lib.concatStringsSep ", " enabled}.";
}
