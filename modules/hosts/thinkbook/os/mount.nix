{ config, lib, pkgs, utils, ... } : let

  cfg = config.modules.hosts.thinkbook;

  bindfsUserMountOptions = builtins.concatStringsSep "," [
    "force-user=${nixosUserName}"
    "force-group=users"
    "perms=u=rwX:g=rX:o="
    "create-as-user"
    "chown-ignore"
    "chgrp-ignore"
  ];

  bindfsFontMountOptions = builtins.concatStringsSep "," [
    "ro"
    "force-user=${nixosRootName}"
    "force-group=root"
    "perms=a=rX"
    "allow_other"
  ];

  nixosUserName = config.users.users."${builtins.toString cfg.users."1000"}".name;

  nixosUserHome = config.users.users."${builtins.toString cfg.users."1000"}".home;

  nixosRootName = config.users.users.root.name;

  nixosSystemFonts = "/usr/local/share/fonts";

in {

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      bindfs
    ];

    programs.fuse = {
      enable = true;
      userAllowOther = true;
    };

    systemd = {
      tmpfiles = {
        rules = [
          "d ${config.fileSystems.windows.mountPoint} 0700 ${nixosRootName} root - -"
          "d ${config.fileSystems.shared.mountPoint} 0700 ${nixosRootName} root - -"
          "d ${nixosSystemFonts}/windows 0555 ${nixosRootName} root - -"
          "d ${nixosUserHome}/knowhub 0755 ${nixosUserName} users - -"
          "d ${nixosUserHome}/ren 0755 ${nixosUserName} users - -"
          "d ${nixosUserHome}/Downloads 0755 ${nixosUserName} users - -"
          "d ${nixosUserHome}/Documents 0755 ${nixosUserName} users - -"
          "d ${nixosUserHome}/Pictures 0755 ${nixosUserName} users - -"
          "d ${nixosUserHome}/Videos 0755 ${nixosUserName} users - -"
          "d ${nixosUserHome}/Music 0755 ${nixosUserName} users - -"
        ];
      };
      mounts = builtins.concatLists [

        (lib.optionals
          config.fileSystems.windows.enable
          [
            {
              what = "${config.fileSystems.windows.mountPoint}/Windows/Fonts";
              where = "${nixosSystemFonts}/windows";
              type = "fuse.bindfs";
              options = bindfsFontMountOptions;
              wantedBy = [ "multi-user.target" ];
              after = [
                "${utils.escapeSystemdPath config.fileSystems.windows.mountPoint}.mount"
              ];
              requires = [
                "${utils.escapeSystemdPath config.fileSystems.windows.mountPoint}.mount"
              ];
            }
          ]
        )

        (lib.optionals
          config.fileSystems.shared.enable
          (lib.mapAttrsToList
            (nixosDirName_ : sourceDirName_ : {
              what = "${config.fileSystems.shared.mountPoint}/${sourceDirName_}";
              where = "${nixosUserHome}/${nixosDirName_}";
              type = "fuse.bindfs";
              options = bindfsUserMountOptions;
              wantedBy = [ "multi-user.target" ];
              after = [
                "${utils.escapeSystemdPath config.fileSystems.shared.mountPoint}.mount"
              ];
              requires = [
                "${utils.escapeSystemdPath config.fileSystems.shared.mountPoint}.mount"
              ];
            })
            {
              ren = "ren";
              knowhub = "knowhub";
              Downloads = "Downloads";
              Documents = "Documents";
              Pictures = "Pictures";
              Music = "Music";
              Videos = "Videos";
            }
          )
        )

      ];
    };

  };

}
