{ pkgs, llib } : let

  lib = pkgs.lib;

  assertEqual = name_ : expected_ : actual_ :
    if actual_ == expected_
    then true
    else throw "Test `${name_}` failed: values differ.";

  assertTrue = name_ : value_ :
    if value_
    then true
    else throw "Test `${name_}` failed: expected true.";

  evaluationFails = value_ : !(builtins.tryEval (builtins.deepSeq value_ true)).success;

  evalMonitors = value_ : (lib.evalModules {
    modules = [
      {
        options.value = lib.mkOption {
          type = llib.types.monitors;
        };
        config.value = value_;
      }
    ];
  }).config.value;

  evalExistModule = modules_ : (lib.evalModules {
    modules = [
      {
        options.value = lib.mkOption {
          type = llib.types.existModule {
            optionPath = "value";
          };
          default = {};
        };
      }
    ] ++ modules_;
  }).config.value;

  monitor_ = (evalMonitors {
    "eDP-1" = {
      mode = {
        width = 3072;
        height = 1920;
        refresh = 120.0;
      };
      scale = 1.5;
    };
  })."eDP-1";

  tests_ = [
    (assertEqual "monitor name default" "eDP-1" monitor_.name)
    (assertEqual "monitor role default" null monitor_.role)
    (assertEqual "monitor width" 3072 monitor_.mode.width)
    (assertEqual "monitor refresh" 120.0 monitor_.mode.refresh)
    (assertEqual "monitor scale" 1.5 monitor_.scale)
    (assertTrue "monitor rejects empty name" (evaluationFails ((evalMonitors {
      broken.name = "";
    }).broken.name)))
    (assertTrue "monitor rejects zero width" (evaluationFails ((evalMonitors {
      broken.mode = {
        width = 0;
        height = 1080;
      };
    }).broken.mode.width)))
    (assertEqual "existModule defaults" { os = null; hm = null; } (evalExistModule []))
    (assertEqual "existModule values" { os = true; hm = false; } (evalExistModule [
      { config.value = { os = true; hm = false; }; }
    ]))
    (assertTrue "existModule rejects duplicate os definitions" (evaluationFails ((evalExistModule [
      { config.value.os = true; }
      { config.value.os = false; }
    ]).os)))
  ];

in assert builtins.deepSeq tests_ true; pkgs.runCommand "nixos-lib-types" {} ''
  touch $out
''
