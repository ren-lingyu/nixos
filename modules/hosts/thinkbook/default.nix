{
  nixosBuilderArgs.hostRegistry.thinkbook = {
    number = 2;

    users = {
      "1000" = 1000;
    };

    monitors = {
      "eDP-1" = {
        name = "eDP-1";
        role = "default";
        mode = {
          width = 3072;
          height = 1920;
          refresh = 60.0;
        };
        scale = 1.6;
      };
      "HDMI-A-1" = {
        name = "HDMI-A-1";
        role = null;
        mode = null;
        scale = 1.0;
      };
    };

    publicIpAddress = null;

    wireguard = {
      publicKey = "XASMyK2E6Jluj1jjsWc4eNXOA5OwjW3E5HlCCocK/BE=";
      privateKey = ./wireguard.private.age;
      listenPort = null;
      endpoint = null;
    };

    identity = {
      rootAccess = true;
      keys = {
        ssh = {
          public = {
            key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOyNxiBW0UgXKhVHB1yo7iFjiVowkIpqNidWKbmual27";
            ageRecipient = "age1ftcurndrgcxtcqd7p4r0z5mwavrt9ux9slvd3zlxqgzn4vs54vqqg0xk3m";
            path = "/etc/ssh/ssh_host_ed25519_key.pub";
          };
          private = {
            key = ./ssh.private.age;
            path = "/etc/ssh/ssh_host_ed25519_key";
          };
        };
      };
    };

    module = {
      imports = [ ./os ];

      base = {
        bluetooth.enable = true;
        bootManager.enable = true;
        networkmanager.enable = true;
        power.enable = true;
      };

      nixpkgs.config.allowUnfreePackages = [
        "github-copilot-cli"
        "microsoft-edge"
        "feishu"
        "zoom"
        "rar"
        "unrar"
      ];
      xdg.createUserDirectories = true;
      services.flatpak.enable = true;
    };
  };
}
