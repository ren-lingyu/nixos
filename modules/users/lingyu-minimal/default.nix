{
  nixosBuilderArgs.userRegistry.lingyu-minimal = {
    identity.keys = {
      age = null;
      ssh = null;
    };
    module = ./hm;
  };
}
