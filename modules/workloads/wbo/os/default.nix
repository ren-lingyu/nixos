{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.workloads.wbo;

in
{
  options.workloads.wbo = {
    enable = lib.mkEnableOption "wbo workload";
    ip = lib.mkOption { type = lib.types.nonEmptyStr; };
    port = lib.mkOption { type = lib.types.port; };
    networkInterface = lib.mkOption { type = lib.types.nonEmptyStr; };
    allowedSourceIp = lib.mkOption { type = lib.types.nonEmptyStr; };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall.extraInputRules = "iifname \"${cfg.networkInterface}\" ip saddr ${cfg.allowedSourceIp} ip daddr ${cfg.ip} tcp dport ${builtins.toString cfg.port} accept";
    };

    containers.wbo = {
      privateNetwork = false;
      autoStart = false;
      restartIfChanged = false;
      config = {
        services.whitebophir = {
          enable = true;
          package = pkgs.whitebophir;
          listenAddress = cfg.ip;
          port = cfg.port;
        };
      };
    };
  };
}
