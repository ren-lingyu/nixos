{ config, pkgs, lib, ... } : {

  config = lib.mkIf config.modules.features.proxy.enable {
    programs.clash-verge = {
      enable = config.modules.features.proxy.clash.enable;
      package = pkgs.clash-verge-rev;
      autoStart = true;
      serviceMode = true;
      tunMode = true;
    };
    services.v2raya = {
      enable = config.modules.features.proxy.v2raya.enable;
      package = pkgs.v2raya;
      cliPackage = pkgs.xray;
    };
  };

}
