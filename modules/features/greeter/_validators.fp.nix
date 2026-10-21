{ path }: {
  configuration =
    {
      lib,
      configuration,
      registry,
      ...
    }:
    let
      cfg = configuration.modules.features.${lib.last path};
      hosts = builtins.attrNames (lib.filterAttrs (_: host: host.enable) configuration.modules.hosts);
    in
    if !cfg.enable || builtins.length hosts != 1 then
      true
    else
      lib.assertMsg (
        lib.count (monitor: monitor.role == "default") (
          builtins.attrValues registry.hosts.${builtins.head hosts}.metadata.monitors
        ) == 1
      ) "Enabled Greeter requires exactly one default monitor in the selected Host.";
}
