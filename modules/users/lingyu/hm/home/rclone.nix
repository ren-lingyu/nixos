{ config, pkgs, ... }: {
  config = {
    programs.rclone = {
      enable = true;
      package = pkgs.rclone;
      remotes = {
        "Nutstore" = {
          config = {
            type = "webdav";
            url = "https://dav.jianguoyun.com/dav/";
            vendor = "other";
          };
          secrets = {
            user = config.secrets.nutstore.user.path;
            pass = config.secrets.nutstore.pass.path;
          };
        };
        "123Cloud" = {
          config = {
            type = "webdav";
            url = "https://webdav.123pan.cn/webdav";
            vendor = "other";
          };
          secrets = {
            user = config.secrets."123cloud".user.path;
            pass = config.secrets."123cloud".pass.path;
          };
        };
        "Cloudflare" = {
          config = {
            type = "s3";
            provider = "Cloudflare";
            region = "auto";
          };
          secrets = {
            access_key_id = config.secrets.cloudflare.access_key_id.path;
            secret_access_key = config.secrets.cloudflare.secret_access_key.path;
            endpoint = config.secrets.cloudflare.endpoint.path;
          };
        };
        "AliCloudOSS" = {
          config = {
            type = "s3";
            provider = "Alibaba";
            acl = "private";
            endpoint = "oss-cn-beijing.aliyuncs.com";
          };
          secrets = {
            access_key_id = config.secrets.alibabacloud.oss.access_key_id.path;
            secret_access_key = config.secrets.alibabacloud.oss.secret_access_key.path;
          };
        };
      };
    };
  };
}
