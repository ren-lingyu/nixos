{ lib } : let

  positiveInt_ = lib.types.addCheck lib.types.ints.unsigned (value_ : value_ > 0);

  positiveFloat_ = lib.types.addCheck lib.types.float (value_ : value_ > 0);

in lib.types.submodule ({ name, ... } : {

  options = {

    name = lib.mkOption {
      type = lib.types.str;
      default = name;
      example = "eDP-1";
      description = "Name of the monitor.";
    };

    role = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "default"
      ]);
      default = null;
      description = "The roles of the monitor.";
    };

    mode = lib.mkOption {
      type = lib.types.nullOr (lib.types.submodule {
        options = {
          width = lib.mkOption {
            type = positiveInt_;
            example = 3072;
            description = "Width of the monitor mode in pixels.";
          };
          height = lib.mkOption {
            type = positiveInt_;
            example = 1920;
            description = "Height of the monitor mode in pixels.";
          };
          refresh = lib.mkOption {
            type = lib.types.nullOr positiveFloat_;
            default = null;
            example = 60.0;
            description = "Refresh rate of the monitor mode in Hz.";
          };
        };
      });
      default = null;
      example = {
        width = 3072;
        height = 1920;
        refresh = 60.0;
      };
      description = "Preferred monitor mode.";
    };

    scale = lib.mkOption {
      type = lib.types.nullOr positiveFloat_;
      default = null;
      example = 1.6;
      description = "Scale of the monitor in pixels.";
    };

  };

})
