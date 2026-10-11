{ lib, path, ... }:
let
  workload_ = lib.last path;
in
{
  configuration = {

    ip = lib.mkOption {
      type = lib.types.functionTo (lib.types.nullOr lib.types.nonEmptyStr);
      default = _: null;
      example = "10.100.3.2";
      description = "IP address of the upstream service proxied by the ${workload_} workload.";
    };

    port = lib.mkOption {
      type = lib.types.functionTo (lib.types.nullOr lib.types.port);
      default = _: null;
      example = 18000;
      description = "Port of the upstream service proxied by the ${workload_} workload.";
    };

    networkInterface = lib.mkOption {
      type = lib.types.functionTo (lib.types.nullOr lib.types.nonEmptyStr);
      default = _: null;
      example = "wg3";
      description = "Host network interface used by the ${workload_} workload to reach its upstream service.";
    };

  };
  metadata = { };
}
