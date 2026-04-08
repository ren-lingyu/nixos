# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      # "video=3840x2400@60"
      "psmouse.synaptics_intertouch=0"
      # "pci=nocrs"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub = {
        fontSize = 32;
      };
    };
  };

  # Configure network connections interactively with nmcli or nmtui.
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
  time = {
    timeZone = "Asia/Shanghai";
  };

  users = {
    users = {
      lingyu = {
        isNormalUser = true;
        linger = true;
        extraGroups = [ "wheel" "video" "render" ];
	      home = "/home/lingyu";	
      };
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [
      "zh_CN.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
    inputMethod = {
      enable = false;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        libpinyin
      ]; 
    };
  };
  
  console = {
    font = "latarcyrheb-sun32";
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      git
      vim
      curl
      wget
      unzip
      gnutar
      gnumake
      fuse
      fuse3
      gcc
      openssh
      gnupg
      pinentry-tty
      pciutils
      vulkan-loader
      vulkan-tools
      microsoft-edge
    ];
    usrbinenv = lib.mkForce "${pkgs.coreutils}/bin/env";
    etc = {
      "libinput/local-overrides.quirks" = {
        text = lib.concatStringsSep "\n" [
          "[Lenovo ThinkBook 14 G8+ IPH touchpad]"
          "MatchName=*GXTP5100*"
          "MatchDMIModalias=dmi:*svnLENOVO:*pvrThinkBook14G8+IPH*:*"
          "MatchUdevType=touchpad"
          "ModelPressurePad=1"
        ];
      };
    };
    variables = {
      EDITOR = "vim";
      DISPLAY = ":0";
    };
    sessionVariables = {};
  };

  programs = {
    nix-ld = {
      enable = true;
    };
    dconf = {
      enable = true;
    };
    ssh = {
      package = pkgs.openssh;
      pubkeyAcceptedKeyTypes = [
        "ssh-ed25519"
      ];
      knownHosts = {
        "github.com" = {
          hostNames = [ "github.com" "ssh.github.com" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
      };
    };
    clash-verge = {
      enable = true;
      package = pkgs.clash-verge-rev;
      autoStart = false;
    };
  };

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "intel" "modesetting" ];
      xkb = {
        layout = "us";
        options = "eurosign:e,caps:escape";
      };
    };
    printing = {
      # Enable CUPS to print documents.
      enable = true;
    };
    libinput = {
      # Enable touchpad support (enabled default in most desktopManager).
      enable = true;
      # touchpad = {
      #   naturalScrolling = true;
      #   tapping = true;
      # };
    };
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager = {
      gnome = {
        enable = true;
      };
    };
    ollama = {
      enable = false;
      package = pkgs.ollama;
      host = "127.0.0.1";
      port = 11434; 
      loadModels = [
	      "qwen3-coder-next:cloud"
        "qwen3.5:cloud"
        "deepseek-v3.2:cloud"
        "gemini-3-flash-preview:cloud"
      ];
      syncModels = true;
    };
  };

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

