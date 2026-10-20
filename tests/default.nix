{
  pkgs,
  llib,
  rootPath,
}:
{

  validators = import ./validators { inherit pkgs llib rootPath; };

  lib-types = import ./lib-types { inherit pkgs llib; };

  host-functions = import ./host-functions { inherit pkgs llib; };

  configuration-adapter = import ./configuration-adapter { inherit pkgs llib; };

  sops-functions = import ./sops-functions { inherit pkgs llib; };

}
