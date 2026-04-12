# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... } : {
  
  imports = [
    ./hardware-configuration.nix
    ./desktop-environment.nix
    ./mount-windows-directory.nix
    ./virtual-terminal.nix
    ./boot-manager.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "psmouse.synaptics_intertouch=0"
    ];
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
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        libpinyin
      ]; 
    };
  };
  
  environment = {
    systemPackages = with pkgs; [
      microsoft-edge
      feishu
      zotero
      calibre
      xournalpp
    ];
    usrbinenv = lib.mkForce "${pkgs.coreutils}/bin/env";
    etc = {
      "libinput/local-overrides.quirks" = {
        text = builtins.concatStringsSep "\n" [
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
      LIBVA_DRIVER_NAME = "iHD";
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
    dbus = {
      enable = true;
      implementation = "broker";
    };
    printing = {
      enable = true;
    };
    pipewire = {
      enable = true;
      pulse = {
        enable = true;
      };
    };
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = false;
        tapping = true;
        scrollMethod = "twofinger";
        disableWhileTyping = true;
      };
    };
    ollama = {
      enable = true;
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
