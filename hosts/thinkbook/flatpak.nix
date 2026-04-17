{ config, lib, pkgs, ... } : {

  services.flatpak = {
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
      {
        appId = "com.github.tchx84.Flatseal";
        origin = "flathub";
      }
      {
        appId = "com.tencent.WeChat";
        origin = "flathub";
      }
      {
        appId = "com.tencent.wemeet";
        origin = "flathub";
      }
    ];
  };

}
