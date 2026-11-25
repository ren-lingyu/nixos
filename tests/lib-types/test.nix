{
  lib,
  runCommand,
  types,
}:
let

  assertEqual =
    name_: expected_: actual_:
    if actual_ == expected_ then true else throw "Test `${name_}` failed: values differ.";

  assertTrue = name_: value_: if value_ then true else throw "Test `${name_}` failed: expected true.";

  evaluationFails = value_: !(builtins.tryEval (builtins.deepSeq value_ true)).success;

  evalMonitors =
    value_:
    (lib.evalModules {
      modules = [
        {
          options.value = lib.mkOption { type = types.monitors; };
          config.value = value_;
        }
      ];
    }).config.value;

  monitor_ =
    (evalMonitors {
      "eDP-1" = {
        mode = {
          width = 3072;
          height = 1920;
          refresh = 120.0;
        };
        scale = 1.5;
      };
    })."eDP-1";

  evalFragment =
    definitions:
    (lib.evalModules {
      modules = [
        { options.value = lib.mkOption { type = types.deferredModuleFragment; }; }
      ]
      ++ definitions;
    }).config.value;

  fragmentFunction = { input, ... }: { value = input; };
  callableFragment = lib.setFunctionArgs (args: { value = args.input; }) { input = false; };

  tests_ = [
    (assertEqual "monitor name default" "eDP-1" monitor_.name)
    (assertEqual "monitor role default" null monitor_.role)
    (assertEqual "monitor width" 3072 monitor_.mode.width)
    (assertEqual "monitor refresh" 120.0 monitor_.mode.refresh)
    (assertEqual "monitor scale" 1.5 monitor_.scale)
    (assertTrue "monitor rejects empty name" (
      evaluationFails ((evalMonitors { broken.name = ""; }).broken.name)
    ))
    (assertTrue "monitor rejects zero width" (
      evaluationFails (
        (evalMonitors {
          broken.mode = {
            width = 0;
            height = 1080;
          };
        }).broken.mode.width
      )
    ))
    (assertEqual "fragment attrset normalization" { value = 42; } (
      (evalFragment [
        {
          value = {
            value = 42;
          };
        }
      ])
        { }
    ))
    (assertEqual "fragment function arguments" (lib.functionArgs fragmentFunction) (
      lib.functionArgs (evalFragment [ { value = fragmentFunction; } ])
    ))
    (assertEqual "fragment callable arguments" (lib.functionArgs callableFragment) (
      lib.functionArgs (evalFragment [ { value = callableFragment; } ])
    ))
    (assertEqual "fragment callable result" { value = 42; } (
      (evalFragment [ { value = callableFragment; } ]) { input = 42; }
    ))
    (assertTrue "fragment rejects non-module input" (
      evaluationFails (evalFragment [ { value = 42; } ])
    ))
    (assertTrue "fragment rejects multiple definitions" (
      evaluationFails (evalFragment [
        {
          value = {
            value = 1;
          };
        }
        {
          value = {
            value = 2;
          };
        }
      ])
    ))
  ];

in
assert builtins.deepSeq tests_ true;
runCommand "nixos-lib-types" { } ''
  touch $out
''
