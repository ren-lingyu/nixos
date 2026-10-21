{ path }: {
  metadata =
    { lib, ... }:
    assert lib.assertMsg false "specific fixture constraint";
    true;
}
