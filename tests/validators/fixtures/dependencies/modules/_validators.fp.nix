{ path }: {
  metadata = { registry, ... }: registry.hosts.thinkbook.metadata.users."1000" == 1000;
  configuration =
    {
      lib,
      configuration,
      registry,
      ...
    }:
    let
      m = configuration.modules;
    in
    assert lib.assertMsg (
      m.users.lingyu.uid == registry.hosts.thinkbook.metadata.users."1000"
    ) "UID default dependency";
    assert lib.assertMsg (
      m.users.lingyu.homeDirectory == "/home/fixture"
    ) "homeDirectory default dependency";
    assert lib.assertMsg (
      m.features.editor.allowUidList == [ 1000 ]
    ) "Feature recipient default dependency";
    assert lib.assertMsg (
      m.features.niri.noctalia.enable == m.features.niri.enable
    ) "Noctalia default dependency";
    assert lib.assertMsg (
      m.features.niri.waybar.enable == (!m.features.niri.noctalia.enable && m.features.niri.enable)
    ) "Waybar default dependency";
    assert lib.assertMsg (lib.isFunction m.workloads.wbo.port) "functionTo must remain unevaluated";
    true;
}
