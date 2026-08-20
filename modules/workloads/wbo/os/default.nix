{ config, pkgs, lib, ... } : let

  cfg = config.modules.workloads.wbo;

in {

  config = lib.mkIf cfg.enable {

    networking = {
      firewall.extraInputRules = "iifname \"${cfg.networkInterface}\" ip saddr ${cfg.allowedSourceIp} ip daddr ${cfg.ip} tcp dport ${builtins.toString cfg.port} accept";
    };

    containers.wbo = {
      privateNetwork = false;
      autoStart = false;
      restartIfChanged = false;
      config = {
        environment.enableAllTerminfo = true;
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
