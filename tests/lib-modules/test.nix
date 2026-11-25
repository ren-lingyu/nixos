{
  lib,
  runCommand,
  mapModule,
}:
let
  fragment = { input, ... }: { value = input; };
  mapped = mapModule (value: { config.result = value.value; }) fragment;
  evaluated = lib.evalModules {
    modules = [
      {
        options.result = lib.mkOption { type = lib.types.int; };
        config._module.args.input = 42;
      }
      mapped
    ];
  };
in
assert lib.functionArgs mapped == lib.functionArgs fragment;
assert (mapped { input = 42; }) == { config.result = 42; };
assert evaluated.config.result == 42;
assert
  (mapModule (value: { payload = value; }) fragment { input = 42; }) == { payload.value = 42; };
runCommand "nixos-lib-modules" { } "touch $out"
