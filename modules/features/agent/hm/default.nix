{ options, config, lib, pkgs, osConfig, ... } : let

  cfg = osConfig.modules.features.agent;

  mifOptions_ = options.moduleInterfaces.features.agent;
  rawMif_ = config.moduleInterfaces.features.agent;

  normalizeProvider_ = agent_ : provider_ : providerConfig_ : lib.mergeAttrsList [
    (builtins.removeAttrs providerConfig_ [ "enable" ])
    {
      enable =
        if mifOptions_.${agent_}.providers.${provider_}.enable.isDefined
        then providerConfig_.enable
        else false;
    }
  ];

  mif = lib.mapAttrs
    (agent_ : agentConfig_ : lib.mergeAttrsList [
      (builtins.removeAttrs agentConfig_ [ "providers" ])
      {
        providers = lib.mapAttrs
          (provider_ : normalizeProvider_ agent_ provider_)
          agentConfig_.providers;
      }
    ])
    rawMif_;

in {

  config = lib.mkIf cfg.enable {

    programs.opencode = {

      enable = true;
      package = pkgs.opencode;
      enableMcpIntegration = false;
      extraPackages = [];

      settings = lib.mergeAttrsList [
        (lib.optionalAttrs mif.opencode.providers.deepseek.enable
          {
            model = "deepseek/deepseek-v4-pro";
            small_model = "deepseek/deepseek-v4-flash";
          }
        )
        {

          permission = "ask";
          autoupdate = false;

          enabled_providers = (builtins.attrNames
            (lib.filterAttrs
              (name_ : value_ : value_.enable == true)
              mif.opencode.providers
            )
          );

          provider = {

            deepseek = lib.mkIf mif.opencode.providers.deepseek.enable {
              name = "DeepSeek";
              options = {
                baseURL = "https://api.deepseek.com";
                apiKey = "{file:${mif.opencode.providers.deepseek.apiKey}}";
              };
              models = {
                deepseek-v4-pro = {
                  name = "DeepSeek-V4-Pro";
                  limit = {
                    context = 1000000;
                    output = 384000;
                  };
                };
                deepseek-v4-flash = {
                  name = "DeepSeek-V4-Flash";
                  limit = {
                    context = 1000000;
                    output = 384000;
                  };
                };
              };
            };

          };

        }
      ];

      context = ./context.md;
      agents = {};
      commands = {};
      skills = ./skills;
      tools = {};
      themes = {};
      tui = {};

      web = {
        enable = false;
        extraArgs = [];
        environmentFile = null;
      };

    };

    programs.pi-coding-agent = let

      final_ = (prev_ : let

        prevExeOutput_ = lib.getBin prev_;
        prevExeOutputVar_ = "$" + (prevExeOutput_.outputName or "out");
        prevExePath_ = lib.getExe prev_;
        prevExeRelPath_ = (
          if lib.hasPrefix "${prevExeOutput_}/" prevExePath_
          then lib.removePrefix "${prevExeOutput_}" prevExePath_
          else builtins.throw "pi-coding-agent executable path ${prevExePath_} is not under ${prevExeOutput_}"
        );

      in prev_.overrideAttrs (oldAttrs: {

        nativeBuildInputs = builtins.concatLists [
          (oldAttrs.nativeBuildInputs or [])
          [ pkgs.makeWrapper ]
        ];
        postFixup = builtins.concatStringsSep "\n" [
          (oldAttrs.postFixup or "")
          ''wrapProgram "${prevExeOutputVar_}${prevExeRelPath_}" --set PI_OFFLINE 1''
        ];

      })) pkgs.pi-coding-agent;

    in {

      enable = true;
      package = final_;

      extraPackages = with pkgs; [
        fd
        ripgrep
        convco
      ];

      context = ./context.md;

      models = let
        cat_ = x_ : "!${lib.getExe' pkgs.coreutils "cat"} ${lib.escapeShellArg x_}";
      in {
        providers = {
          deepseek = lib.mkIf mif.pi.providers.deepseek.enable {
            api = "openai-completions";
            baseUrl = "https://api.deepseek.com";
            apiKey = cat_ mif.pi.providers.deepseek.apiKey;
          };
        };
      };

      settings = {
        defaultProjectTrust = "ask";
        enableInstallTelemetry = false;
        skills = [
          "${./skills}"
        ];
      };

    };

    programs.codex = {
      enable = true;
      package = pkgs.codex;
      context = ./context.md;
      skills = ./skills;
    };

    programs.github-copilot-cli = {
      enable = true;
      package = pkgs.github-copilot-cli;
      context = ./context.md;
      skills = ./skills;
    };

    assertions = builtins.concatLists (lib.mapAttrsToList
      (agent_ : agentConfig_ : lib.mapAttrsToList
        (provider_ : providerConfig_ : {
          assertion = (builtins.any
            (x_ : x_)
            [
              (!providerConfig_.enable)
              mifOptions_.${agent_}.providers.${provider_}.apiKey.isDefined
            ]
          );
          message = "`moduleInterfaces.features.agent.${agent_}.providers.${provider_}.enable = true` requires `moduleInterfaces.features.agent.${agent_}.providers.${provider_}.apiKey` to be defined.";
        })
        agentConfig_.providers)
      mif);

  };

}
