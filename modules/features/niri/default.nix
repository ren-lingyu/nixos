{
  nixosBuilderArgs.featureRegistry = {
    os.niri = ./os;
    hm.niri = ./hm;
  };
}
