{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = {
    programs.fastfetch = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.fastfetch;
      settings = lib.mkDefault { };
    };
    xdg = {
      enable = true;
      cacheHome = "${config.home.homeDirectory}/.cache";
      configHome = "${config.home.homeDirectory}/.config";
      binHome = "${config.home.homeDirectory}/.local/bin";
      dataHome = "${config.home.homeDirectory}/.local/share";
      stateHome = "${config.home.homeDirectory}/.local/state";
      userDirs = {
        enable = lib.mkForce osConfig.modules.share.createXdgUserDirectories;
        createDirectories = lib.mkForce osConfig.modules.share.createXdgUserDirectories;
        package = pkgs.xdg-user-dirs;
        desktop = "${config.home.homeDirectory}/Desktop";
        download = "${config.home.homeDirectory}/Downloads";
        documents = "${config.home.homeDirectory}/Documents";
        pictures = "${config.home.homeDirectory}/Pictures";
        videos = "${config.home.homeDirectory}/Videos";
        music = "${config.home.homeDirectory}/Music";
        templates = "${config.home.homeDirectory}/Templates";
        projects = "${config.home.homeDirectory}/Projects";
        publicShare = "${config.home.homeDirectory}/Public";
      };
    };
    home = {
      stateVersion = "26.05";
      preferXdgDirectories = config.xdg.enable;
    };
  };
}
