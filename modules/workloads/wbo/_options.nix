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
      description = "IP address on which the whitebophir service in the ${workload_} workload listens.";
    };

    port = lib.mkOption {
      type = lib.types.functionTo (lib.types.nullOr lib.types.port);
      default = _: null;
      example = 18000;
      description = "Port on which the whitebophir service in the ${workload_} workload listens.";
    };

    networkInterface = lib.mkOption {
      type = lib.types.functionTo (lib.types.nullOr lib.types.nonEmptyStr);
      default = _: null;
      example = "wg3";
      description = "Host network interface from which the ${workload_} workload accepts traffic.";
    };

    allowedSourceIp = lib.mkOption {
      type = lib.types.functionTo (lib.types.nullOr lib.types.nonEmptyStr);
      default = _: null;
      example = "10.100.3.3";
      description = "Source IP address allowed to access the ${workload_} workload.";
    };

  };
  metadata = { };
}
