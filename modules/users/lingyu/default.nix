{ config, lib, pkgs, ... } : {

  imports = [
    ./hm
  ];

  config = {
    moduleInterfaces.features.secret.sops = {
      defaultSopsFormat = "yaml";
      defaultSopsFile = ./sops/default.yaml;
      secretsInput = [
        {
          template = "user";
          structure = {
            "nutstore" = [ "user" "pass" ];
            "123cloud" = [ "user" "pass" ];
            "cloudflare" = [ "access_key_id" "secret_access_key" "endpoint" ];
            "onedrive" = [ "token" "drive_id" ];
            "alibabacloud" = {
              "oss" = [ "access_key_id" "secret_access_key" ];
            };
          };
        }
        {
          template = "user";
          structure = {
            "deepseek" = {
              "apiKey" = [ "opencode" "pi" ];
            };
            "ollama" = {
              "apiKey" = [ "opencode" ];
            };
            "modelscope" = {
              "apiKey" = [ "opencode" ];
            };
          };
        }
      ];
    };
  };

}
