# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let

  bindfsMountOptions = lib.concatStringsSep "," [
    "force-user=lingyu"
    "force-group=users"
    "perms=u=rwX:g=rX:o="
    "create-as-user"
    "chown-ignore"
    "chgrp-ignore"
  ];
  nixosUserHome = "/home/lingyu";
  windowsUserHome = "/mnt/c/Users/Lingyu";

in

{
  
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      # "video=3072x1920@60"
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
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
    proxy = {
      default = ""; #"http://user:password@proxy:port/";
      noProxy = ""; #"127.0.0.1,localhost,internal.domain";
    };
  };
  
  time = {
    timeZone = "Asia/Shanghai";
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = "$y$j9T$I75rvRCS.FR8zj/o3ivGb1$lteEgidoSR8AbjTXhxfemLeiXFIQsxUuUmSl1f0Ni10";
      };
      lingyu = {
        isNormalUser = true;
        hashedPassword = "$y$j9T$HZvnP.0ZR5uBiDAviT9xA.$MSExGgePZwjIDZq2n3fOUGGguWKEgvjuIKImW4uf7p4";
        linger = true;
        extraGroups = [ "wheel" "video" "render" ];
	      home = nixosUserHome;
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
      enable = true;
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
      bindfs
      microsoft-edge
      feishu
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
    sessionVariables = {
      GTK_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      QT_IM_MODULE = "ibus";
    };
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
    gnupg = {
      package = pkgs.gnupg;
      agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-tty;
      };
    };
    clash-verge = {
      enable = true;
      package = pkgs.clash-verge-rev;
      autoStart = false;
      serviceMode = true;
      tunMode = true;
    };
  };

  services = {
    openssh = {
      enable = true;
    };
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
    pipewire = {
      enable = true;
      pulse = {enable = true;};
    };
    libinput = {
      # Enable touchpad support (enabled default in most desktopManager).
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
      };
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
    gnome = {
      gnome-keyring = {
        enable = false;
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

  systemd = {
    tmpfiles = {
      rules = [
        "d /mnt/c 0700 root root - -"
        "d ${nixosUserHome}/knowhub 0755 lingyu users - -"
        "d ${nixosUserHome}/Downloads 0755 lingyu users - -"
        "d ${nixosUserHome}/Documents 0755 lingyu users - -"
        "d ${nixosUserHome}/Pictures 0755 lingyu users - -"
        "d ${nixosUserHome}/Videos 0755 lingyu users - -"
        "d ${nixosUserHome}/Music 0755 lingyu users - -"
      ];
    };
    mounts = [
      {
        what = "${windowsUserHome}/KnowledgeHub";
        where = "${nixosUserHome}/knowhub";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/Downloads";
        where = "${nixosUserHome}/Downloads";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/OneDrive/Documents";
        where = "${nixosUserHome}/Documents";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/OneDrive/Pictures";
        where = "${nixosUserHome}/Pictures";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/OneDrive/Videos";
        where = "${nixosUserHome}/Videos";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/OneDrive/Music";
        where = "${nixosUserHome}/Music";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
    ];
  };

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

