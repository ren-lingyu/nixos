{
  nixosBuilderArgs.featureRegistry = {
    os.agent = ./os;
    hm.agent = ./hm;
  };
}
