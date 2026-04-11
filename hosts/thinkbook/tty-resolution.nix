{ config, lib, pkgs, ... }:

let

  forceFb0 = pkgs.writeShellScript "force-fb0-3072x1920" (lib.concatStringsSep "\n" [
    "set -eu"
    "[ -e /dev/fb0 ] || exit 0"
    "exec ${pkgs.fbset}/bin/fbset -fb /dev/fb0 -g 3072 1920 3072 1920 32"
  ]);
  
  udevRule = lib.concatStringsSep ", " [
    "ACTION==\"change\""
    "SUBSYSTEM==\"drm\""
    "KERNEL==\"card0\""
    "TAG+=\"systemd\""
    "ENV{SYSTEMD_WANTS}+=\"fbset-on-drm-change.service\""
  ];

in

{

  environment.systemPackages = with pkgs; [ fbset ];

  systemd.services = {
    fbset-before-display-manager = {
      description = "Force fb0 mode to 3072x1920 before display-manager (greeter)";
      wantedBy = [ "display-manager.service" ];
      before = [ "display-manager.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = forceFb0;
      };
    };
    fbset-on-drm-change = {
      description = "Force fb0 mode to 3072x1920 on drm card0 change";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = forceFb0;
      };
    };
  };

  services.udev.extraRules = udevRule;

}
