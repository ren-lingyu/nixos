{
  nixosBuilderArgs.featureRegistry = {
    os.editor = ./os;
    hm.editor = ./hm;
  };
}
