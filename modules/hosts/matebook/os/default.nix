# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, ... } : let

  cfg = config.modules.hosts.matebook;

in {

  imports = [
    ./hardware-configuration.nix
  ];

  config = lib.mkIf cfg.enable {

    nix.settings = {
      trusted-users = [ "@wheel" "root" ];
    };

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      loader = {
        systemd-boot = {
          enable = false;
        };
        efi = {
          canTouchEfiVariables = true;
        };
        limine = {
          enable = true;
          secureBoot = {
            enable = true;
          };
        };
      };
    };

    hardware = {
      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-vaapi-driver
          vpl-gpu-rt
          intel-compute-runtime
        ];
      };
      enableRedistributableFirmware = true;
      uinput.enable = true;
    };

    networking = {
      hostName = "nixos-matebook";
    };

    time = {
      timeZone = "Asia/Shanghai";
    };

    environment = {
      systemPackages = with pkgs; [
        usbutils
      ];
      usrbinenv = lib.mkForce "${pkgs.coreutils}/bin/env";
      variables = {
        EDITOR = "vim";
      };
    };

    users = {
      mutableUsers = false;
      users = {
        root = {
          name = "root";
          hashedPassword = "$y$j9T$3zzZQHdL7iI.V/dVUa.ti0$eiiWaYqAixyLkt5nCft3X.o5OkxpIXpz3p.hrzL0Hf1";
        };
        "${builtins.toString cfg.users."1000"}" = {
          uid = cfg.users."1000";
          isNormalUser = true;
          hashedPassword = "$y$j9T$ckTNGDz1gOk0jJWnABn0U0$8GnjsLLNYSeVRIwoFS9VusrMGKfNBQXNcyoQlGEJYMB";
          linger = true;
          extraGroups = builtins.concatLists [
            [ "wheel" "video" "render" "input" ]
            (lib.optionals config.networking.networkmanager.enable [ "networkmanager" ])
            (lib.optionals config.services.seatd.enable [ config.services.seatd.group ])
          ];
          packages = with pkgs; [];
          openssh = {
            authorizedKeys = {
              keys = [
                config.modules.hosts.thinkbook.identityKeys.ssh.public.key
              ];
            };
          };
        };
      };
    };

    security = {
      pam = {
        package = pkgs.pam;
      };
      rtkit = {
        enable = true;
      };
      polkit = {
        enable = true;
        package = pkgs.polkit;
      };
    };

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocales = [
        "zh_CN.UTF-8/UTF-8"
        "de_DE.UTF-8/UTF-8"
      ];
      # extraLocaleSettings = {
      #   LC_ADDRESS = "zh_CN.UTF-8";
      #   LC_IDENTIFICATION = "zh_CN.UTF-8";
      #   LC_MEASUREMENT = "zh_CN.UTF-8";
      #   LC_MONETARY = "zh_CN.UTF-8";
      #   LC_NAME = "zh_CN.UTF-8";
      #   LC_NUMERIC = "zh_CN.UTF-8";
      #   LC_PAPER = "zh_CN.UTF-8";
      #   LC_TELEPHONE = "zh_CN.UTF-8";
      #   LC_TIME = "zh_CN.UTF-8";
      # };
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          ignoreUserConfig = false;
          waylandFrontend = true;
          addons = with pkgs; [
            fcitx5-gtk
            (fcitx5-rime.override {
              rimeDataPkgs = [
                pkgs.rime-ice
              ];
            })
          ];
          quickPhrase = {};
          quickPhraseFiles = {};
          settings = {
            addons = {};
            globalOptions = {};
            inputMethod = {};
          };
        };
      };
    };

    services.seatd = {
      enable = true;
      group = "seat";
    };

    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        options = "eurosign:e,caps:escape";
      };
    };

    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    services.openssh = {
      enable = true;
      hostKeys = [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    services.fprintd = {
      enable = false;
    };

    services.dbus = {
      enable = true;
      implementation = "broker";
    };

    services.printing = {
      enable = true;
    };

    services.libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = false;
        tapping = true;
        scrollMethod = "twofinger";
        disableWhileTyping = true;
      };
    };


    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "26.11"; # Did you read the comment?
  };

}
