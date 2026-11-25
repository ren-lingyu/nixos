{
  nixosBuilderArgs.featureRegistry = {
    os.x11-session = ./os;
    hm.x11-session = ./hm;
  };
}
