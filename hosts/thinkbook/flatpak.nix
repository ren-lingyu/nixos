{ config, lib, pkgs, ... } : {

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
    enable = true;
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
        Environment = config.environment.sessionVariables;
      };
      "${flatpakPackages.wemeet.appId}" = {
        Context = {
          filesystems = [
            "xdg-documents/TencentMeeting:create"
            "xdg-download"
          ];
        };
      };
      "${flatpakPackages.wechat.appId}" = {
        Context = {
          filesystems = [
            "xdg-documents/xwechat_files:create"
            "xdg-download"
          ];
        };
      };
      "${flatpakPackages.qq.appId}" = {
        Context = {
          filesystems = [
            "xdg-documents/Tensent Files:create"
            "xdg-download"
          ];
        };
      };
    };
  };  

}
