{
  lib,
  stdenvNoCC,
  installAgentSkills,
} : stdenvNoCC.mkDerivation {

  pname = "git-maintenance";
  version = "0.3.0";

  src = ./.;

  nativeBuildInputs = [
    installAgentSkills
  ];

  dontConfigure = true;
  dontBuild = true;

  meta = {
    description = "Repository-generic Git maintenance skill for coding agents";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };

}
