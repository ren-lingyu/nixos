{
  nixosBuilderArgs.userRegistry.lingyu = {
    module = ./hm;

    sops = {
      defaultSopsFormat = "yaml";
      defaultSopsFile = ./sops/default.yaml;
      secretsInput = [
        {
          template = "user";
          structure = {
            "nutstore" = [
              "user"
              "pass"
            ];
            "123cloud" = [
              "user"
              "pass"
            ];
            "cloudflare" = [
              "access_key_id"
              "secret_access_key"
              "endpoint"
            ];
            "onedrive" = [
              "token"
              "drive_id"
            ];
            "alibabacloud" = {
              "oss" = [
                "access_key_id"
                "secret_access_key"
              ];
            };
          };
        }
        {
          template = "user";
          structure = {
            "deepseek" = {
              "apiKey" = [ "pi" ];
            };
            "moonshot" = {
              "cn" = {
                "apiKey" = [ "pi" ];
              };
            };
            "zai" = {
              "cn" = {
                "apiKey" = [ "pi" ];
              };
            };
          };
        }
      ];
    };
    agent.pi.apiKeySecrets = {
      deepseek = "deepseek.apiKey.pi";
      moonshot-cn = "moonshot.cn.apiKey.pi";
      zai-cn = "zai.cn.apiKey.pi";
    };
  };
}
