{ lib, ... }: {
  nixosBuilderArgs.baseModule = {
    imports = [ ./os ];
    home-manager.sharedModules = lib.mkAfter [ ./hm ];
  };
}
