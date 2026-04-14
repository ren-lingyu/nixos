{ config, lib, pkgs, ... } : {

  services.flatpak = {
    enable = false;
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
    packages = [];
  };

}
