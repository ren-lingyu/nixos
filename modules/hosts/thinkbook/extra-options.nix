host_ : { options, config, pkgs, lib, llib, ... } : {

  packageGroups = {
    tencent.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to install Tencent package group on this host.";
    };
  };

  flatpak = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable Flatpak.";
    };
  };

}
