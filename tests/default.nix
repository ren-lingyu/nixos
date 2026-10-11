{ pkgs, llib }: {

  lib-types = import ./lib-types { inherit pkgs llib; };

  exist-module-assertions = import ./exist-module-assertions { inherit pkgs llib; };

  host-functions = import ./host-functions { inherit pkgs llib; };

  module-composition = import ./module-composition { inherit pkgs llib; };

  configuration-adapter = import ./configuration-adapter { inherit pkgs llib; };

  sops-functions = import ./sops-functions { inherit pkgs llib; };

}
