{ lib, path, ... }: {
  configuration =
    { configuration, ... }:
    let
      cfg = configuration.modules.hosts.${lib.last path};
    in
    lib.assertMsg (
      !cfg.flatpak.enable || cfg.enable
    ) "ThinkBook Flatpak requires ThinkBook to be enabled.";
}
