{ pkgs, llib } : {

  lib-types = import ./lib-types {
    inherit pkgs llib;
  };

  exist-module-assertions = import ./exist-module-assertions {
    inherit pkgs llib;
  };

  feature-import-grouping = import ./feature-import-grouping {
    inherit pkgs llib;
  };

  module-composition = import ./module-composition {
    inherit pkgs llib;
  };

  sops-functions = import ./sops-functions {
    inherit pkgs llib;
  };

}
