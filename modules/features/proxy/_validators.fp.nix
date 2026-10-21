{ path }: {
  configuration =
    { lib, configuration, ... }:
    let
      cfg = configuration.modules.features.${lib.last path};
    in
    assert lib.assertMsg (builtins.all (child: !cfg.${child}.enable || cfg.enable) [
      "clash-verge"
      "throne"
      "mihomo"
      "v2raya"
    ]) "Enabled Proxy children require Proxy to be enabled.";
    lib.assertMsg (
      !(cfg.clash-verge.enable && cfg.mihomo.enable)
    ) "Proxy clash-verge and mihomo cannot both be enabled.";
}
