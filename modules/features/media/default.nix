{
  nixosBuilderArgs.featureRegistry = {
    os.media = ./os;
    hm.media = ./hm;
  };
}
