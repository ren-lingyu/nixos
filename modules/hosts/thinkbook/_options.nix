{ lib, ... }: {

  flatpak = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable Flatpak.";
    };
  };

}
