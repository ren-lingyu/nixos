{ lib, ... }: {
  metadata =
    _:
    assert lib.assertMsg false "specific fixture constraint";
    true;
}
