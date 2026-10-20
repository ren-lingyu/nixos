{ path, ... }:
assert
  path == [
    "modules"
    "features"
  ];
{
  metadata = { registry, ... }: registry.features.alpha.metadata.number != 2;
  configuration = { configuration, ... }: configuration.specialArgs.category or true;
}
