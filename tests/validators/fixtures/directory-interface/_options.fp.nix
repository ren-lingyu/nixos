{ lib, path, ... }:
assert
  path == [
    "modules"
    "features"
    "alpha"
  ];
{
  metadata.marker = lib.mkOption {
    type = lib.types.int;
    default = 42;
  };
}
