{ config, lib, pkgs, ... } : let

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
  nixosUserName = config.users.users.lingyu.name;
  nixosUserHome = config.users.users.lingyu.home;
  nixosRootName = config.users.users.root.name;
  windowsUserHome = "/mnt/c/Users/Lingyu";
  windowsSystemFonts = "/mnt/c/Windows/Fonts";
  nixosSystemFonts = "/usr/local/share/fonts";

in {

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
        "d /mnt/c 0700 ${nixosRootName} root - -"
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
    mounts = [
      {
        what = "${windowsSystemFonts}";
        where = "${nixosSystemFonts}/windows";
        type = "fuse.bindfs";
        options = bindfsFontMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/KnowledgeHub";
        where = "${nixosUserHome}/knowhub";
        type = "fuse.bindfs";
        options = bindfsUserMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/Ren";
        where = "${nixosUserHome}/ren";
        type = "fuse.bindfs";
        options = bindfsUserMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/Downloads";
        where = "${nixosUserHome}/Downloads";
        type = "fuse.bindfs";
        options = bindfsUserMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/Documents";
        where = "${nixosUserHome}/Documents";
        type = "fuse.bindfs";
        options = bindfsUserMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/Pictures";
        where = "${nixosUserHome}/Pictures";
        type = "fuse.bindfs";
        options = bindfsUserMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/Videos";
        where = "${nixosUserHome}/Videos";
        type = "fuse.bindfs";
        options = bindfsUserMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/Music";
        where = "${nixosUserHome}/Music";
        type = "fuse.bindfs";
        options = bindfsUserMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
    ];
  };
  
}
