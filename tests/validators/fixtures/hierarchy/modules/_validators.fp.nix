args@{ path, ... }:
assert
  builtins.attrNames args == [
    "lib"
    "llib"
    "path"
  ];
assert path == [ "modules" ];
{
  metadata = { registry, ... }: registry.features.alpha.metadata.number != 0;
  configuration = { configuration, ... }: configuration.specialArgs.root or true;
}
