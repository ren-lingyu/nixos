{
  host,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./boot-manager.nix
    ./identity.nix
    ./shared.nix
    ./ssh-targets.nix
    ./wireguard.nix
  ];

  options.xdg.createUserDirectories = lib.mkEnableOption "XDG user directory creation";

  config = {
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        sandbox = true;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    environment = {
      systemPackages = with pkgs; [
        vim
        curl
        wget
        gnutar
        gzip
        ncurses
        kitty.terminfo
        foot.terminfo
        tmux.terminfo
      ];
    };

    networking = {
      nftables.enable = true;
      firewall.enable = true;
    };

    services.userborn = {
      enable = true;
      package = pkgs.userborn;
    };

    age = {
      identityPaths = [ host.identity.keys.ssh.private.path ];
      rekey = {
        storageMode = "derivation";
        masterIdentities = [
          {
            identity = "/var/lib/master-key";
            pubkey = "age1zds7ax4umgu9wjwn7yvp4gndv6fl7h2f8ycwa0edx2pgcdqq53ds9jlxt9";
          }
          {
            identity = (builtins.toFile "yubikey-age-identity.pub" "AGE-PLUGIN-YUBIKEY-103W9VQ5ZGQSWUMG8DVKUQ");
            pubkey = "age1yubikey1qd0j85pkw0a6zjt4xy7ez0t7ehc6u9dqwjgjj5hh55dftvzlk9hyuxgl6c9";
          }
        ];
        hostPubkey = host.identity.keys.ssh.public.key;
      };
    };

    systemd.services = {
      "user@" = {
        after = [ "agenix-install-secrets.service" ];
        overrideStrategy = "asDropin";
      };
    };

    programs.git = {
      enable = true;
      package = pkgs.gitFull;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
    };
  };
}
