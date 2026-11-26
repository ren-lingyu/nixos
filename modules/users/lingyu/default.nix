{
  nixosBuilderArgs.userRegistry.lingyu = {
    module = ./hm;

    identity.keys = {
      age = {
        public.key = "age1kgwar87m34mfg5zhtywg42umlax77y28tvucu0wkdwrq870wdf9s782jqe";
        private.key = ./age.private.age;
      };
      ssh = null;
    };

    features.sops.module =
      {
        config,
        osConfig,
        llib,
        ...
      }:
      {
        ageKeyFile = osConfig.age.secrets.${llib.identity.userAgeSecretName config.home.uid}.path;
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
    features.agent.module = { config, lib, ... }: {
      pi.providers = lib.mkIf (config.features.sops.enable or false) {
        deepseek = {
          enable = true;
          apiKeyFile = config.sops.secrets."deepseek.apiKey.pi".path;
        };
        moonshot-cn = {
          enable = true;
          apiKeyFile = config.sops.secrets."moonshot.cn.apiKey.pi".path;
        };
        zai-cn = {
          enable = true;
          apiKeyFile = config.sops.secrets."zai.cn.apiKey.pi".path;
        };
      };
    };
  };
}
