workload_ : { options, config, pkgs, lib, llib, ... } : {

  ip = lib.mkOption {
    type = lib.types.nullOr lib.types.nonEmptyStr;
    default = null;
    example = "10.100.3.2";
    description = "IP address on which the whitebophir service in the ${workload_} workload listens.";
  };

  port = lib.mkOption {
    type = lib.types.nullOr lib.types.port;
    default = null;
    example = 18000;
    description = "Port on which the whitebophir service in the ${workload_} workload listens.";
  };

  networkInterface = lib.mkOption {
    type = lib.types.nullOr lib.types.nonEmptyStr;
    default = null;
    example = "wg3";
    description = "Host network interface from which the ${workload_} workload accepts traffic.";
  };

  allowedSourceIp = lib.mkOption {
    type = lib.types.nullOr lib.types.nonEmptyStr;
    default = null;
    example = "10.100.3.3";
    description = "Source IP address allowed to access the ${workload_} workload.";
  };

}
