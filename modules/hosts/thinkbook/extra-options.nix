host_ : { options, config, pkgs, lib, llib, ... } : {

  flatpak = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable Flatpak.";
    };
  };

  windows = {
    mount = {
      enable = lib.mkOption {
        type = lib.types.bool;
        internal = true;
        readOnly = true;
        example = true;
        description = "Whether to mount windows directory.";
      };
    };
    virtualisation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        internal = true;
        readOnly = true;
        example = true;
        description = "Whether to virtualize windows.";
      };
    };
  };

}
