{ config, pkgs, lib, ... } : let

  cfg = config.modules.hosts.thinkbook;

in {

  config = lib.mkIf (builtins.all
    (x_ : x_ == true)
    (with cfg; [
      enable
      windows.virtualisation.enable
    ])
  ) {

    environment.systemPackages = with pkgs; [
      freerdp
    ];

    networking.firewall.interfaces = {
      "virbr0" = {
        allowedTCPPorts = [
          53
        ];
        allowedUDPPorts = [
          53
          67
        ];
      };
    };

    virtualisation = {

      libvirtd = {
        enable = true;
        package = pkgs.libvirt;
        hooks = {
          qemu = {
            windows-reset-method = (pkgs.writeShellScript
              "windows-reset-method"
              (builtins.readFile ./reset-method.sh)
            );
          };
        };
      };

      libvirt = {
        enable = true;
        package = config.virtualisation.libvirtd.package;
        verbose = true;
        swtpm = {
          enable = false;
        };
        connections = {
          "qemu:///system" = {
            domains = [
              {
                definition = ./domain.xml;
                restart = false;
                active = null;
              }
            ];
            networks = [
              {
                definition = ./network.xml;
                restart = false;
                active = true;
              }
            ];
            pools = null;
          };
        };
      };

    };

  };

}
