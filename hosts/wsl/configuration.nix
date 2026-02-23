# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
    ];
  };

  # imports = [
  #   # include NixOS-WSL modules
  #   <nixos-wsl/modules>
  # ];
  
  wsl = {
    enable = true;
    defaultUser = "lingyu";
    interop = {
      includePath = false;
      register = true;   
    };
    wslConf = {
      automount = {
        enabled = true;
        root = "/mnt";
      };
    };
    startMenuLaunchers = true;
    docker-desktop.enable = true;
    useWindowsDriver = true;
  };

  users = {
    groups.docker = {};
    users.lingyu = {
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      home = "/home/lingyu";
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nixpkgs.config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) [
    "github-copilot-cli"
  ];

  environment = {
    systemPackages = with pkgs; [
      dbus
      git
      vim
      wget
      curl
      wget
      ripgrep
      htop
      unzip
      gnutar
      tree
      gnumake
      jq
      rclone
      fuse
      fuse3
      ghostscript
      gcc
      openssh
      gnupg
      pinentry-tty
      vulkan-loader
      vulkan-tools
    ];
    usrbinenv = lib.mkForce "${pkgs.coreutils}/bin/env";
    binsh = "${pkgs.bash}/bin/sh";
    variables = {
      EDITOR = "vim";
    }; 
  };
    
  services = {
    dbus = {
      enable = true;
      implementation = "broker";
    };
    vscode-server = {
      enable = true;
      enableFHS = true;
    };
    ollama = {
      enable = true;
      package = pkgs.ollama;
      host = "127.0.0.1";
      port = 11434; 
      loadModels = [
        "phi4-mini-reasoning:3.8b-q4_K_M"
      ];
      syncModels = true;
    };
  };

  programs = {
    nix-ld.enable = true;
    dconf.enable = true;
  }; 

  systemd = {
    services = {
      "user@" = {
        overrideStrategy = "asDropin";
        serviceConfig = {
          Delegate = "no";
          DelegateSubgroup = "";
        };
      };
    };
    tmpfiles.rules = [
      "f /var/lib/systemd/linger/lingyu 0644 root root -"
    ];
  };
  
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      fcitx5-rime
    ];
  };
  
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    wqy_zenhei
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
