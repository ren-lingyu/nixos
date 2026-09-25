{ stdenvNoCC, fetchFromGitHub, lib } : stdenvNoCC.mkDerivation rec {

  pname = "luadraw";
  version = "3.4";

  src = fetchFromGitHub {
    owner = "pfradin";
    repo = "luadraw";
    rev = "32bed27969eeff7e968622eaf29483d2846e792e";
    fetchSubmodules = false;
    hash = "sha256-BZ+tJ95pRpLXfCfw5WSBMkDkxvqlYivuXRZiXUR7M2s=";
  };

  dontBuild = true;
  dontStrip = true;

  outputs = [ "out" "tex" "texdoc" ];

  passthru = {
    tlType = "run";
    tlDeps = ps_ : with ps_; [
      latex
      iftex
      luacode
      tools
      xkeyval
      pgf
    ];
  };

  installPhase = lib.concatStringsSep "\n" [
    "runHook preInstall"
    ""
    "mkdir -p \"$out\""
    ""
    "mkdir -p \"$tex/tex/lualatex/${pname}\""
    "cp -r files/* \"$tex/tex/lualatex/${pname}/\""
    ""
    "mkdir -p \"$texdoc/doc/lualatex/${pname}\""
    "cp -r doc/* \"$texdoc/doc/lualatex/${pname}/\""
    ""
    "runHook postInstall"
  ];

  meta = with lib; {
    description = "LuaLaTeX package ${pname} version ${version} for creating mathematical drawings";
    homepage = "https://github.com/pfradin/luadraw";
    license = licenses.lppl13c;
    platforms = platforms.all;
    maintainers = [ ];
  };

}
