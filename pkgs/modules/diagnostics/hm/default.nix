{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.features.diagnostics.enable = lib.mkEnableOption "Home Manager diagnostic tools";

  config = lib.mkIf config.features.diagnostics.enable {
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
      settings = { };
      themes = { };
    };
  };
}
