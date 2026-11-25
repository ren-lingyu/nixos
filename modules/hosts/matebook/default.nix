{
  nixosBuilderArgs.hostRegistry.matebook = {
    number = 4;

    users = {
      "1000" = 1000;
    };

    monitors = {
      "eDP-1" = {
        name = "eDP-1";
        role = "default";
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        scale = 1.0;
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
      publicKey = "NNYzfM8sckCYE6ytb+szZ7fwbnsD+Ka+siyxgxFzGXs=";
      privateKey = ./wireguard.private.age;
      listenPort = null;
      endpoint = null;
    };

    identity = {
      rootAccess = true;
      keys = {
        ssh = {
          public = {
            key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGHXTx6ixiEtNlE+BbIuXipDEx0cSCeI8nAQig0PV3hn";
            ageRecipient = "age1ej6d66ejr34rkeurfmq4ncw6xzq42pfww5x5stlk738xl4la059syqh8q7";
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
        wireguard.firewall.restrictOutput = false;
      };

      nixpkgs.config.allowUnfreePackages = [ "github-copilot-cli" ];
      xdg.createUserDirectories = true;
    };
  };
}
