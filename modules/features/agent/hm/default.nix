{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  providers = config.features.agent.pi.providers;
  providerEnabled =
    name: options.features.agent.pi.providers.${name}.enable.isDefined && providers.${name}.enable;

  context_ = import ./context {
    inherit pkgs lib;
    git = (if config.programs.git.package == null then pkgs.git else config.programs.git.package);
    git-agent-workflow = pkgs.git-agent-workflow;
  };

  packagesWithSkills_ = lib.optionals config.programs.git.enable (
    with pkgs;
    [
      git-agent-workflow
      git-maintenance
    ]
  );

  skills_ = lib.listToAttrs (
    map (p_: {
      name = p_.pname;
      value = "${p_}/share/skills/${p_.pname}";
    }) packagesWithSkills_
  );
in
{
  options = {
    features.agent.pi.providers = lib.genAttrs (import ./providers.nix) (provider: {
      enable = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        description = "Whether to enable the ${provider} provider.";
      };
      apiKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;
        readOnly = true;
        description = "Runtime path to the ${provider} API key.";
      };
    });

    features.agent.enable = lib.mkEnableOption "Home Manager agent tools";
  };

  config = lib.mkIf config.features.agent.enable {
    home = {
      packages = builtins.concatLists [ packagesWithSkills_ ];
      file = {
        ".agents/AGENTS.md" = {
          enable = true;
          text = context_;
        };
        ".agents/skills" = {
          enable = true;
          source = pkgs.linkFarm "agents-skills" skills_;
          recursive = true;
        };
      };
    };

    programs.pi-coding-agent = {
      enable = true;
      package = pkgs.pi-coding-agent;

      extraPackages = with pkgs; [
        fd
        ripgrep
        convco
        wl-clipboard
        xclip
      ];

      context = context_;

      models =
        let
          cat_ = x_: "!${lib.getExe' pkgs.coreutils "cat"} ${lib.escapeShellArg x_}";
        in
        {
          providers = {
            deepseek = lib.mkIf (providerEnabled "deepseek" && providers.deepseek.apiKeyFile != null) {
              apiKey = cat_ providers.deepseek.apiKeyFile;
            };
            moonshotai-cn = lib.mkIf (
              providerEnabled "moonshot-cn" && providers.moonshot-cn.apiKeyFile != null
            ) { apiKey = cat_ providers.moonshot-cn.apiKeyFile; };
            zai-api-cn = lib.mkIf (providerEnabled "zai-cn" && providers.zai-cn.apiKeyFile != null) {
              api = "openai-completions";
              baseUrl = "https://open.bigmodel.cn/api/paas/v4";
              apiKey = cat_ providers.zai-cn.apiKeyFile;
              compat = {
                thinkingFormat = "zai";
                supportsReasoningEffort = true;
              };
              models =
                builtins.map
                  (
                    x_:
                    x_
                    // {
                      thinkingLevelMap = {
                        off = null;
                        minimal = null;
                        low = "low";
                        medium = null;
                        high = "high";
                        xhigh = null;
                        max = "max";
                      };
                    }
                  )
                  [
                    {
                      id = "glm-5.3";
                      name = "GLM-5.3";
                      reasoning = true;
                      input = [ "text" ];
                      contextWindow = 1000000;
                      maxTokens = 131072;
                    }
                    {
                      id = "glm-5.3-flash";
                      name = "GLM-5.3 Flash";
                      reasoning = true;
                      input = [
                        "text"
                        "image"
                      ];
                      contextWindow = 1000000;
                      maxTokens = 131072;
                    }
                    {
                      id = "glm-5.3-flashx";
                      name = "GLM-5.3 FlashX";
                      reasoning = true;
                      input = [
                        "text"
                        "image"
                      ];
                      contextWindow = 1000000;
                      maxTokens = 131072;
                    }
                  ];
            };
          };
        };

      settings = {
        defaultProjectTrust = "ask";
        enableInstallTelemetry = false;
        packages = [
          "${pkgs.piPackages.pi-mono-context}"
          "${pkgs.piPackages.pi-mono-web-search}"
          "${pkgs.piPackages.pi-agentic-search}"
          "${pkgs.piPackages.pi-workspace-history}"
        ];
      };
    };

    programs.codex = {
      enable = true;
      package = pkgs.codex;
      context = context_;
    };

    programs.github-copilot-cli = {
      enable = true;
      package = pkgs.github-copilot-cli;
      context = context_;
      skills = skills_;
    };

    assertions = lib.mapAttrsToList (name: provider: {
      assertion = !providerEnabled name || provider.apiKeyFile != null;
      message = "Enabled Agent provider ${name} requires features.agent.pi.providers.${name}.apiKeyFile.";
    }) providers;
  };
}
