{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    sbctl
    efitools
  ];

  boot.loader = {
    systemd-boot = {
      enable = false;
      consoleMode = "auto";
    };
    efi = {
      canTouchEfiVariables = true;
    };
    limine = {
      enable = true;
      package = pkgs.limine;
      resolution = "3072x1920";
      efiSupport = true;
      validateChecksums = true;
      maxGenerations = null;
      extraEntries = lib.concatStringsSep "\n" [
        (lib.concatStringsSep "\n\t" [
          "/Windows 11"
          "protocol: efi_chainload"
          "path: boot():/EFI/Microsoft/Boot/bootmgfw.efi"
        ])
      ];
      secureBoot = {
        enable = true;
        sbctl = pkgs.sbctl;
        createAndEnrollKeys = false; # NOT INTENDED to be seted as true on a real system.
      };
      style = {
        wallpapers = [];
        wallpaperStyle = "stretched"; # "stretched" or "tiled" or "centered"
        backdrop = "000000";
        interface = {
          resolution = "3072x1920";
          helpHidden = false;
          brandingColor = 7; # 0=black 1=red 2=green 3=yellow 4=blue 5=purple 6=cyan 7=white
          branding = "NixOS - Limine Bootloader";
        };
        graphicalTerminal = {
          palette = "000000;AA0000;00AA00;AA5500;0000AA;AA00AA;00AAAA;AAAAAA";
          brightPalette = "555555;FF5555;55FF55;FFFF55;5555FF;FF55FF;55FFFF;FFFFFF";
          foreground = "FFFFFF";
          background = "000000";
          brightForeground = "FFFF55";
          brightBackground = "0000AA";
          margin = 0;
          marginGradient = 0; 
          font = {
            spacing = 0;
            scale = null;
          };
        };
      };
    };
  };

}
