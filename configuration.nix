# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  # imports = [
  #   # include NixOS-WSL modules
  #   <nixos-wsl/modules>
  # ];

  wsl = {
    enable = true;
    defaultUser = "lingyu";
    interop = {
      includePath = true;
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
  };

  users.groups.docker = {};
  users.users.lingyu = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    home = "/home/lingyu";
  };
  
  services = {
    dbus = {
      enable = true;
      packages = [ pkgs.dbus ];
    };
    vscode-server = {
      enable = true;
      enableFHS = true;
    };
  };

  programs.nix-ld.enable = true;

  environment = {
    usrbinenv = lib.mkForce "${pkgs.coreutils}/bin/env";
    binsh = "${pkgs.bash}/bin/sh";
  };

  systemd.user.services."dbus" = {
    description = "D-Bus User Message Bus";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.dbus}/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile";
      Restart = "on-failure";
    };
  };

  programs.dconf.enable = true;
  
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    dbus
    git
    vim
    wget
    qt6Packages.fcitx5-configtool
  ];
  environment.variables.EDITOR = "vim";
}
