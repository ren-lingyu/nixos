{ lib, path, ... }: {
  configuration =
    { configuration, registry, ... }:
    let
      cfg = configuration.modules.features.${lib.last path};
      hosts = builtins.attrNames (lib.filterAttrs (_: host: host.enable) configuration.modules.hosts);
    in
    assert lib.assertMsg (!cfg.waybar.enable || cfg.enable) "Niri Waybar requires Niri to be enabled.";
    assert lib.assertMsg (!cfg.noctalia.enable || cfg.enable) "Noctalia requires Niri to be enabled.";
    assert lib.assertMsg (
      !(cfg.waybar.enable && cfg.noctalia.enable)
    ) "Niri Waybar and Noctalia cannot both be enabled.";
    if !cfg.enable || builtins.length hosts != 1 then
      true
    else
      lib.assertMsg (
        lib.count (monitor: monitor.role == "default") (
          builtins.attrValues registry.hosts.${builtins.head hosts}.metadata.monitors
        ) == 1
      ) "Enabled Niri requires exactly one default monitor in the selected Host.";
}
