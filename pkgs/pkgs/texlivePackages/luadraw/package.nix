{
  stdenvNoCC,
  src,
  lib,
}:
stdenvNoCC.mkDerivation rec {
  inherit src;

  pname = "luadraw";
  version =
    let
      matched = builtins.match ".*ProvidesPackage[^[]*\\[[^]]*version ([0-9][0-9.]*).*" (
        builtins.readFile "${src}/files/luadraw.sty"
      );
    in
    if matched == null then
      throw "luadraw: cannot extract the package version from files/luadraw.sty"
    else
      builtins.head matched;

  dontBuild = true;
  dontStrip = true;

  outputs = [
    "out"
    "tex"
    "texdoc"
  ];

  passthru = {
    tlType = "run";
    tlDeps =
      ps_: with ps_; [
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
