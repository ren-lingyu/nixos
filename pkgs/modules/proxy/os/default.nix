{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.features.proxy;

in
{
  options.features.proxy = {
    enable = lib.mkEnableOption "proxy configuration";
    clash-verge.enable = lib.mkEnableOption "clash-verge";
    throne.enable = lib.mkEnableOption "throne";
    mihomo.enable = lib.mkEnableOption "mihomo";
    v2raya.enable = lib.mkEnableOption "v2raya";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.clash-verge.enable && cfg.mihomo.enable);
        message = "Clash Verge and Mihomo cannot both be enabled.";
      }
    ];

    programs.clash-verge = lib.mkIf cfg.clash-verge.enable {
      enable = cfg.clash-verge.enable;
      package = pkgs.clash-verge-rev.override {
        v2ray-domain-list-community = pkgs.v2ray-rules-dat;
        v2ray-geoip = pkgs.v2ray-rules-dat;
      };
      autoStart = false;
      serviceMode = true;
      tunMode = true;
    };

    programs.throne = lib.mkIf cfg.throne.enable {
      enable = cfg.throne.enable;
      package = pkgs.throne;
      tunMode = {
        enable = true;
        setuid = false;
      };
    };

    services.mihomo = lib.mkIf cfg.mihomo.enable {
      enable = cfg.mihomo.enable;
      package = pkgs.mihomo;
      tunMode = true;
      webui = pkgs.metacubexd;
      processesInfo = false;
      extraOpts = null;
      configFile = "/etc/mihomo/config.yaml";
    };

    services.v2raya = lib.mkIf cfg.v2raya.enable {
      enable = cfg.v2raya.enable;
      package = pkgs.v2raya;
      cliPackage = pkgs.xray;
    };
  };
}
