{
  lib,
  makeWrapper,
  pi-coding-agent,
} : let

  prevExeOutput_ = lib.getBin pi-coding-agent;
  prevExeOutputVar_ = "$" + (prevExeOutput_.outputName or "out");
  prevExePath_ = lib.getExe pi-coding-agent;
  prevExeRelPath_ = (
    if lib.hasPrefix "${prevExeOutput_}/" prevExePath_
    then lib.removePrefix "${prevExeOutput_}" prevExePath_
    else builtins.throw "pi-coding-agent executable path ${prevExePath_} is not under ${prevExeOutput_}"
  );

in (pi-coding-agent.overrideAttrs
  (oldAttrs_ : {

    nativeBuildInputs = builtins.concatLists [
      (oldAttrs_.nativeBuildInputs or [])
      [ makeWrapper ]
    ];

    postFixup = builtins.concatStringsSep "\n" [
      (oldAttrs_.postFixup or "")
      "wrapProgram \"${prevExeOutputVar_}${prevExeRelPath_}\" --set PI_OFFLINE 1"
    ];

  })
)
