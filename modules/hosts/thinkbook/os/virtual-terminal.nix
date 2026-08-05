{ config, lib, pkgs, ... } : let

  cfg = config.modules.hosts.thinkbook;

in {

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      fbset
    ];

    systemd.services.fbset-xedrmfb = {
      enable = true;
      description = "Set the initial xe framebuffer geometry";
      wantedBy = [
        "display-manager.service"
      ];
      before = [
        "display-manager.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = (pkgs.writeShellScript
          "force-fb0-3072x1920"
          (builtins.concatStringsSep "\n" [
            "set -eu"
            "[ -r /sys/class/graphics/fb0/name ] || exit 0"
            "IFS= read -r fbName < /sys/class/graphics/fb0/name"
            "[ \"$fbName\" = xedrmfb ] || exit 0"
            "exec ${pkgs.fbset}/bin/fbset -fb /dev/fb0 -g 3072 1920 3072 1920 32"
          ])
        );
      };
    };

    services.udev = {
      enable = true;
      extraRules = (builtins.concatStringsSep "," [
        "ACTION==\"add\""
        "SUBSYSTEM==\"graphics\""
        "KERNEL==\"fb0\""
        "ATTR{name}==\"xedrmfb\""
        "TAG+=\"systemd\""
        "ENV{SYSTEMD_WANTS}+=\"fbset-xedrmfb.service\""
      ]);
    };

    console = {
      enable = true;
      font = "latarcyrheb-sun32";
      # font = "Lat2-Terminus16";
      # keyMap = "us";
      useXkbConfig = true; # use xkb.options in tty.
    };

    services.kmscon = {
      enable = true;
      useXkbConfig = true;
      config = {
        libseat = false;
        font-engine = "pango";
        font-name = "Maple Mono NF CN";
        font-size = 24;
        use-original-mode = true;
        multi-monitor = "clone";
        sb-size = 10000;
      };
    };

  };

}
