{ config, lib, pkgs, osConfig, ... } : let

  cfg = osConfig.modules.features.diagnostics;

in {

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      dnsutils
      mtr
      netcat
      nmap
      pciutils
      socat
      tcpdump
    ];

    programs.btop = {
      enable = true;
      package = pkgs.btop;
      settings = {};
      themes = {};
    };

  };

}
