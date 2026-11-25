{
  nixosBuilderArgs.featureRegistry = {
    os.sops = ./os;
    hm.sops = ./hm;
  };
}
