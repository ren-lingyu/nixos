host_ : { config, pkgs, lib, llib, ... } : {

  users = {
    "1000" = 1000;
  };

  monitors = {
    "eDP-1" = {
      name = "eDP-1";
      role = "default";
      mode = {
        width = 3072;
        height = 1920;
        refresh = 60.0;
      };
      scale = 1.6;
    };
    "HDMI-A-1" = {
      name = "HDMI-A-1";
      role = null;
      mode = null;
      scale = 1.0;
    };
  };

}
