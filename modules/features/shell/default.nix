{
  nixosBuilderArgs.featureRegistry = {
    os.shell = ./os;
    hm.shell = ./hm;
  };
}
