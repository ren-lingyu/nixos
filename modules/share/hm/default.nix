{
  rootPath,
  options,
  config,
  osConfig,
  pkgs,
  lib,
  llib,
  ...
}:
let
  moduleRootPath_ = rootPath + "/modules";
in
{

  options = {
    moduleInterfaces = (
      lib.genAttrs
        (builtins.attrNames (
          lib.filterAttrs (
            name_: type_:
            (builtins.all (x_: x_) [
              (type_ == "directory")
              (builtins.pathExists (moduleRootPath_ + "/${name_}/default.nix"))
            ])
          ) (builtins.readDir moduleRootPath_)
        ))
        (
          moduleType_:
          (lib.genAttrs
            (builtins.attrNames (
              lib.filterAttrs (
                name_: type_:
                (builtins.all (x_: x_) [
                  (type_ == "directory")
                  (builtins.pathExists (moduleRootPath_ + "/${moduleType_}/${name_}/default.nix"))
                ])
              ) (builtins.readDir (moduleRootPath_ + "/${moduleType_}"))
            ))
            (
              module_:
              let
                possibleInterfaceOptionsPath_ =
                  moduleRootPath_ + "/${moduleType_}/${module_}/hm/interface-options.nix";
              in
              (lib.optionalAttrs (builtins.pathExists possibleInterfaceOptionsPath_) (
                (import possibleInterfaceOptionsPath_) module_ {
                  inherit options;
                  inherit config;
                  inherit osConfig;
                  inherit pkgs;
                  inherit lib;
                  inherit llib;
                }
              ))
            )
          )
        )
    );
  };

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
        enable = lib.mkForce osConfig.modules.base.createXdgUserDirectories;
        createDirectories = lib.mkForce osConfig.modules.base.createXdgUserDirectories;
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
