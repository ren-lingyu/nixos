args@{ path }:
assert builtins.attrNames args == [ "path" ];
assert path == [ "modules" ];
{
  metadata =
    {
      lib,
      llib,
      registry,
    }:
    assert lib.assertMsg (llib.marker == 42) "metadata library context";
    registry.features.alpha.metadata.number != 0;
  configuration =
    {
      lib,
      llib,
      name,
      configuration,
      registry,
    }:
    assert lib.assertMsg (llib.marker == 42) "configuration library context";
    configuration.specialArgs.root or true;
}
