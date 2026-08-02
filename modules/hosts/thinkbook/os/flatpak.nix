{ config, lib, pkgs, ... } : let

  cfg = config.modules.hosts.thinkbook;

in {

  config = lib.mkIf (cfg.enable && cfg.flatpak.enable) {

    xdg.portal.enable = lib.mkIf config.services.flatpak.enable (lib.mkForce true);

    services.flatpak = let
      flatpakPackages = {
        flatseal = {
          appId = "com.github.tchx84.Flatseal";
          origin = "flathub";
        };
        wechat = {
          appId = "com.tencent.WeChat";
          origin = "flathub";
        };
        qq = {
          appId = "com.qq.QQ";
          origin = "flathub";
        };
        wemeet = {
          appId = "com.tencent.wemeet";
          origin = "flathub";
        };
      };
    in {
      enable = cfg.flatpak.enable;
      package = pkgs.flatpak;
      uninstallUnmanaged = true;
      update = {
        onActivation = true;
        auto = {
          enable = false;
          onCalendar = "weekly";
        };
      };
      remotes = [
        {
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
      ];
      packages = [
        flatpakPackages.flatseal
        flatpakPackages.wemeet
        flatpakPackages.wechat
        flatpakPackages.qq
      ];
      overrides = {
        global = {
          Environment = {};
          Context = {
            sockets = [
              "x11"
              "wayland"
              # "fallback-x11"
            ];
            shared = [
              "network"
            ];
            devices = [
              "all"
            ];
            features = [
              "bluetooth"
            ];
            filesystems = [
              "xdg-pictures"
              "xdg-download"
              "xdg-documents"
            ];
          };
        };
        "${flatpakPackages.wemeet.appId}" = {
          Context = {
            filesystems = [
              "xdg-documents/TencentMeeting:create"
            ];
          };
        };
        "${flatpakPackages.wechat.appId}" = {
          Context = {
            filesystems = [
              "xdg-documents/xwechat_files:create"
            ];
          };
        };
        "${flatpakPackages.qq.appId}" = {
          Context = {
            filesystems = [
              "xdg-documents/Tencent Files:create"
            ];
          };
        };
      };
    };

  };

}
