{
  imports = [ ./secrets ];

  nixosBuilderArgs.userRegistry.lingyu = {
    module = ./hm;

    identity.keys = {
      age = {
        public.key = "age1kgwar87m34mfg5zhtywg42umlax77y28tvucu0wkdwrq870wdf9s782jqe";
        private.key = ./age.private.age;
      };
      ssh = null;
    };

    features.agent.module = { config, ... }: {
      pi.providers = {
        deepseek = {
          enable = true;
          apiKeyFile = config.secrets.deepseek.apiKey.pi.path;
        };
        moonshot-cn = {
          enable = true;
          apiKeyFile = config.secrets.moonshot.cn.apiKey.pi.path;
        };
        zai-cn = {
          enable = true;
          apiKeyFile = config.secrets.zai.cn.apiKey.pi.path;
        };
      };
    };
  };
}
