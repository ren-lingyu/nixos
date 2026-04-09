{ config, lib, pkgs, ... }:

let

  bindfsMountOptions = lib.concatStringsSep "," [
    "force-user=lingyu"
    "force-group=users"
    "perms=u=rwX:g=rX:o="
    "create-as-user"
    "chown-ignore"
    "chgrp-ignore"
  ];
  nixosUserHome = "/home/lingyu";
  windowsUserHome = "/mnt/c/Users/Lingyu";

in

{

  systemd = {
    tmpfiles = {
      rules = [
        "d /mnt/c 0700 root root - -"
        "d ${nixosUserHome}/knowhub 0755 lingyu users - -"
        "d ${nixosUserHome}/Downloads 0755 lingyu users - -"
        "d ${nixosUserHome}/Documents 0755 lingyu users - -"
        "d ${nixosUserHome}/Pictures 0755 lingyu users - -"
        "d ${nixosUserHome}/Videos 0755 lingyu users - -"
        "d ${nixosUserHome}/Music 0755 lingyu users - -"
      ];
    };
    mounts = [
      {
        what = "${windowsUserHome}/KnowledgeHub";
        where = "${nixosUserHome}/knowhub";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/Downloads";
        where = "${nixosUserHome}/Downloads";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/OneDrive/Documents";
        where = "${nixosUserHome}/Documents";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/OneDrive/Pictures";
        where = "${nixosUserHome}/Pictures";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/OneDrive/Videos";
        where = "${nixosUserHome}/Videos";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
      {
        what = "${windowsUserHome}/OneDrive/Music";
        where = "${nixosUserHome}/Music";
        type = "fuse.bindfs";
        options = bindfsMountOptions;
        wantedBy = [ "multi-user.target" ];
        after = [ "mnt-c.mount" ];
        requires = [ "mnt-c.mount" ];
      }
    ];
  };
  
}
