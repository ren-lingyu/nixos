{ pkgs, llib } : let

  assertEqual = name_ : expected_ : actual_ :
    if actual_ == expected_
    then true
    else throw "Test `${name_}` failed: values differ.";

  assertTrue = name_ : value_ :
    if value_
    then true
    else throw "Test `${name_}` failed: expected true.";

  validAssertions_ = llib.assertions.existModule {
    enable = true;
    value = {
      os = true;
      hm = false;
    };
    optionPath = "test.existModule";
    osModulePath = ./default.nix;
    hmModulePath = ./. + "/missing.nix";
    enabledMessage = "Both module declarations are required.";
  };

  invalidAssertions_ = llib.assertions.existModule {
    enable = true;
    value = {
      os = null;
      hm = null;
    };
    optionPath = "test.existModule";
    osModulePath = ./default.nix;
    hmModulePath = ./. + "/missing.nix";
    enabledMessage = "Both module declarations are required.";
  };

  tests_ = [
    (assertTrue "matching paths" (builtins.all (assertion_ : assertion_.assertion) validAssertions_))
    (assertEqual "enabled profiles require declarations" false (builtins.elemAt invalidAssertions_ 3).assertion)
    (assertEqual "enabled message passthrough" "Both module declarations are required." (builtins.elemAt invalidAssertions_ 3).message)
  ];

in assert builtins.deepSeq tests_ true; pkgs.runCommand "nixos-exist-module-assertions" {} ''
  touch $out
''
