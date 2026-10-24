{ path }:
assert path == [ "modules" ];
{
  metadata = { registry, ... }: registry.marker == 42;
}
