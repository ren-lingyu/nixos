{ config, lib, pkgs, ... } : {

  config = {

    programs.rclone = {
      enable = true;
      package = pkgs.rclone;
      requiresUnit = "sops-nix.service";
      remotes = {
        "Nutstore" = {
          config = {
            type = "webdav";
            url = "https://dav.jianguoyun.com/dav/";
            vendor = "other";
          };
          secrets = {
            user = config.sops.secrets."nutstore.user".path;
            pass = config.sops.secrets."nutstore.pass".path;
          };
        };
        "123Cloud" = {
          config = {
            type = "webdav";
            url = "https://webdav.123pan.cn/webdav";
            vendor = "other";
          };
          secrets = {
            user = config.sops.secrets."123cloud.user".path;
            pass = config.sops.secrets."123cloud.pass".path;
          };
        };
        "Cloudflare" = {
          config = {
            type = "s3";
            provider = "Cloudflare";
            region = "auto";
          };
          secrets = {
            access_key_id = config.sops.secrets."cloudflare.access_key_id".path;
            secret_access_key = config.sops.secrets."cloudflare.secret_access_key".path;
            endpoint = config.sops.secrets."cloudflare.endpoint".path;
          };
        };
        "OneDrive" = {
          config = {
            type = "onedrive";
            drive_type = "personal";
          };
          secrets = {
            token = config.sops.secrets."onedrive.token".path;
            drive_id = config.sops.secrets."onedrive.drive_id".path;
          };
        };
      };
    };

  };

}
