{
  nixosBuilderArgs.featureRegistry = {
    os.file-manager = ./os;
    hm.file-manager = ./hm;
  };
}
