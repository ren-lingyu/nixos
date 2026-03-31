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
      linger = true;
      extraGroups = [ "wheel" "docker" ];
      home = "/home/lingyu";
      openssh = {
        authorizedKeys = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJGeBOS0SKejDDcOPOWD106pexJwLjsl7PFIuXSyZtYp lingyu@DESKTOP-NIM6ULV"
          ];
        };
      };
    };
  };
  
  nixpkgs.config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) [
    "github-copilot-cli"
  ];
  
  environment = {
    systemPackages = with pkgs; [
      wslu
      dbus
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
      vulkan-loader
      vulkan-tools
      gsettings-desktop-schemas
      nodejs_22
    ];
    usrbinenv = lib.mkForce "${pkgs.coreutils}/bin/env";
    # binsh = "${pkgs.bash}/bin/sh";
    variables = {
      EDITOR = "vim";
      # DISPLAY = "localhost:0.0";
    };
    sessionVariables = {
      BROWSER = "${pkgs.wslu}/bin/wslview";
    };
  };

  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/https" = "wslview.desktop";
        "x-scheme-handler/http" = "wslview.desktop";
        "text/html" = "wslview.desktop";
        "text/xml" = "wslview.desktop";
        "application/xhtml+xml" = "wslview.desktop";
        "application/pdf" = "wslview.desktop";
        "x-scheme-handler/about" = "wslview.desktop";
        "x-scheme-handler/unknown" = "wslview.desktop";
      };
    };
    portal = {
      enable = false;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
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
  };
  
  services = {
    dbus = {
      enable = true;
      implementation = "broker";
    };
    vscode-server = {
      enable = true;
      enableFHS = true;
      # nodejsPackage = pkgs.nodejs_22; # 强制指定该选项可能会导致问题, 建议保持默认.
    };
    # 用来提供远程访问. 
    # 本意是在 Remote-WSL 失效后的替代, 但现在似乎没用了. 
    openssh = {
      enable = false;
      ports = [2222];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        UseDns = false;
      };
      listenAddresses = [ 
        { 
          addr = "127.0.0.1"; 
          port = 2222; 
        }
      ];
    };
  };
  
  systemd = {
    services = {
      "user@" = {
        enable = true;
        overrideStrategy = "asDropin";
        serviceConfig = {
          # 不要全局设置 Delegate = "no". 
          Delegate = "pids memory cpu";
          DelegateSubgroup = "init.scope";
        };
      };
    };
    user = {
      services = {
        auto-fix-vscode-server = {
          enable = false;
          serviceConfig = {
            # 保证 vscode-server 正常运行.
            # 有默认选项: Restart = "always". 不要在这里修改. 
            Delegate = "no"; 
          };
        };
        emacs = {
          enable = true;
          overrideStrategy = "asDropin";
          path = [
            "/usr"
            "/Docker/host"
          ];
          serviceConfig = {
            Restart = "on-failure";
            Delegate = "yes";
          };
        };
        # 采用 x410 作为 X server
        x410-bridge = {
          enable = false;
          description = "X410 bridge via socat";
          wantedBy = [ "default.target" ];
          after = [ "default.target" ];
          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            KillMode = "control-group";
            ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %t/.x410";
            ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:%t/.x410/X0,fork,unlink-early TCP:localhost:6000";
          };
        };
      };
    };
    tmpfiles.rules = [
      "L+ %t/wayland-0 - - - - /mnt/wslg/runtime-dir/wayland-0"
      "L+ %t/wayland-0.lock - - - - /mnt/wslg/runtime-dir/wayland-0.lock"
    ];
  };

  i18n.inputMethod = {
    enable = false;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-rime
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "pinyin";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
          };
          "Groups/0/Items/1" = {
            Name = "pinyin";
          };
          "GroupOrder" = {
            "0" = "Default";
          };
        };
        globalOptions = {
          "Hotkey/TriggerKeys" = {
            "0" = "Control+Control_L";
            "1" = "Control+Control_R";
          };
          "Behavior" = {
            ActiveByDefault = false;
            resetStateWhenFocusIn = "No";
            ShareInputState = "No";
            PreeditEnabledByDefault = true;
            ShowInputMethodInformation = true;
            showInputMethodInformationWhenFocusIn = false;
            CompactInputMethodInformation = true;
            ShowFirstInputMethodInformation = true;
            PreloadInputMethod = true;
            AllowInputMethodForPassword = false;
            ShowPreeditForPassword = false;
            AutoSavePeriod = 30;
          };
        }; 
      };
    };
  };
  
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    wqy_zenhei
    nerd-fonts.meslo-lg
  ];
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
