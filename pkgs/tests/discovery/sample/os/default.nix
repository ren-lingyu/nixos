{ lib, ... }: {
  options.sample = lib.mkOption { type = lib.types.str; };
  config.sample = "discovered";
}
