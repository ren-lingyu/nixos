feature_ : { options, config, osConfig, pkgs, lib, llib, ... } : {

  inherit (lib.mapAttrs
    (agent_ : providers_ : {
      providers = lib.mapAttrs
        (provider_ : unused_ : {

          enable = lib.mkOption {
            type = lib.types.unique {
              message = "Conflicting definitions for `moduleInterfaces.features.${feature_}.${agent_}.providers.${provider_}.enable`.";
            } lib.types.bool;
            default = false;
            internal = true;
            description = "Whether to enable the ${provider_} provider for ${agent_}.";
          };

          apiKey = lib.mkOption {
            type = lib.types.unique {
              message = "Conflicting definitions for `moduleInterfaces.features.${feature_}.${agent_}.providers.${provider_}.apiKey`.";
            } lib.types.nonEmptyStr;
            internal = true;
            description = "Path to the file containing the ${provider_} API key used by ${agent_}.";
          };

        })
        providers_;
    })
    {
      opencode = {
        deepseek = {};
      };
      pi = {
        deepseek = {};
      };
    }
  ) opencode pi;

}
