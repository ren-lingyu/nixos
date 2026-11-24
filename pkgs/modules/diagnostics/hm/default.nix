{ pkgs, ... }: {
  config = {
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
