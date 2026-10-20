{ ... }: {
  configuration =
    { name, ... }:
    assert name != "assertion";
    name != "invalid";
}
