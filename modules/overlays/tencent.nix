{ config, pkgs, lib, ... } : {

  config = {
    nixpkgs.overlays = [
      (final: prev: {
        qq = prev.qq.overrideAttrs (_old: {
          version = "3.2.29-2026-05-28";
          src = final.fetchurl {
            url = "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.31/release/00e6a3e7/QQ_3.2.29_260528_amd64_01.deb";
            hash = "sha256-HjgoB5ZzyUmUvA9HgNXYUoZHY5kgZZhi1J0cLyoZjiU=";
          };
        });
        wechat = final.callPackage (prev.path + "/pkgs/by-name/we/wechat/linux.nix") {
          pname = "wechat";
          version = "4.1.1.4";
          src = final.fetchurl {
            url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
            hash = "sha256-vTTkuFm1LhAqVvuynIfYdROPf19nfCQIOGhw6Z+dOeo=";
          };
          meta = prev.wechat.meta;
        };
      })
    ];
  };

}
