{ pkgs, llib }:
let
  lib = pkgs.lib;

  options_ = {
    plain = lib.mkOption { type = lib.types.bool; };
    package = lib.mkOption { type = lib.types.functionTo lib.types.str; };
    nested = lib.mkOption {
      type = lib.types.submodule {
        options.value = lib.mkOption { type = lib.types.functionTo lib.types.str; };
      };
    };
    untouched = lib.mkOption { type = lib.types.raw; };
  };

  config_ = {
    plain = true;
    package = { value, ... }: value;
    nested.value = { value, ... }: "nested-${value}";
    untouched = {
      function = _: "Do not call this function";
    };
  };

  result_ = llib.moduleFunctions.configuration.adaptOptions options_ config_ { value = "resolved"; };

in
assert result_.plain;
assert result_.package == "resolved";
assert result_.nested.value == "nested-resolved";
assert builtins.isFunction result_.untouched.function;
pkgs.runCommand "nixos-configuration-adapter" { } ''
  touch $out
''
