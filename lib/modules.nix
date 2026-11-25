{ lib }: {
  mapModule = f: module: lib.setFunctionArgs (args: f (module args)) (lib.functionArgs module);
}
