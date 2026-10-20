{ path, ... }:
assert
  path == [
    "modules"
    "features"
    "alpha"
  ];
{
  metadata = { registry, ... }: registry.features.alpha.metadata.number != 3;
  configuration = { configuration, ... }: configuration.specialArgs.module or true;
}
