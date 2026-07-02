{ config, pkgs, lib, ... } : {
  
  config = lib.mkIf config.modules.hosts.aliyun.enable {
    
    nix.settings = {
      trusted-users = [ "@wheel" "root" ];
    };
    
    networking = {
      hostName = "nixos-server";
      useDHCP = lib.mkDefault true;
    };

    time.timeZone = "Asia/Shanghai";

    i18n.defaultLocale = "en_US.UTF-8";

    boot.loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        devices = [
          "nodev"
        ];
      };
    };
    
    users = {
      mutableUsers = false;
      users = {
        root = {
          name = "root";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCnfaTNuw0Wxh4CfReEKqqU2rT8HqPG/M1HmiDwr0Ry Ren_Lingyu@outlook.com"
          ];
        };
        "1000" = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [
            "wheel"
          ];
          openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
          hashedPassword = "$y$j9T$1J6tPBiaxfJB6.VP/3CJa.$/LrO/IUrSNylYEWrgQ7EJMhyCnP8aHrDu5C13T.UnF0";
        };
      };
    };

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PubkeyAuthentication = true;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
    
    security.sudo.wheelNeedsPassword = false;
    
    system.stateVersion = "26.11";

  };
  
}
