{ config, lib, pkgs, ... } : let

  cfg = config.programs.wayfile;

in {

  options.programs.wayfile = {

    enable = lib.mkEnableOption "Wayfile";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../package.nix { };
      description = "The Wayfile package to install.";
    };

    desktopFileName = lib.mkOption {
      type = lib.types.unique {
        message = "The Wayfile desktop file name must be defined only once.";
      } lib.types.str;
      internal = true;
      description = "Internal desktop file name installed by the Wayfile package.";
    };

    mimeTypes = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      example = [
        "inode/directory"
      ];
      description = "MIME types to associate with Wayfile when `programs.wayfile.mimeTypes` is not null.";
    };

  };

  config = lib.mkMerge [

    { programs.wayfile.desktopFileName = "io.github.blackbartblues.Wayfile.desktop"; }

    (lib.mkIf cfg.enable {

      home.packages = [
        cfg.package
      ];

      xdg.mimeApps = lib.mkIf (cfg.mimeTypes != null) {
        enable = true;
        defaultApplications = builtins.listToAttrs (builtins.map (mimeType : {
          name = mimeType;
          value = cfg.desktopFileName;
        }) cfg.mimeTypes);
      };

    })

  ];

}
