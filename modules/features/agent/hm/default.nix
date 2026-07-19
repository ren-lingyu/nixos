{ config, lib, pkgs, osConfig, ... } : let

  cfg = osConfig.modules.features.agent;

in {

  config = lib.mkIf cfg.enable {

    programs.aichat = {
      enable = osConfig.services.ollama.enable;
      package = pkgs.aichat;
      settings = {
        model = "ollama:deepseek-v3.2:cloud";
        clients = [
          {
            type = "openai-compatible";
            name = "ollama";
            api_base = "http://${osConfig.services.ollama.host}:${builtins.toString osConfig.services.ollama.port}/v1";
            models = [
              {
                name = "deepseek-v3.2:cloud";
                supports_function_calling = false;
                supports_vision = false;
              }
            ];
          }
        ];
      };
    };

    programs.opencode = {

      enable = true;
      package = pkgs.opencode;
      enableMcpIntegration = false;
      extraPackages = [];

      settings = {

        permission = "ask";
        model = "deepseek/deepseek-v4-pro";
        small_model = "deepseek/deepseek-v4-flash";
        autoupdate = false;

        enabled_providers = builtins.concatLists [
          [ "deepseek" "modelscope" ]
          (lib.optionals osConfig.services.ollama.enable [ "ollama" "ollama_cloud" ])
        ];

        provider = let

          fromList = list : builtins.listToAttrs (
            builtins.map (x : {
              name = builtins.toString x;
              value = {
                name = builtins.toString x;
              };
            }) list
          );

        in (lib.mergeAttrsList [

          {

            deepseek = {
              name = "DeepSeek";
              options = {
                baseURL = "https://api.deepseek.com";
                apiKey = "{file:${config.sops.secrets."deepseek.apiKey.opencode".path}}";
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

            modelscope = {
              name = "ModelScope";
              options = {
                baseURL = "https://api-inference.modelscope.cn/v1";
                apiKey = "{file:${config.sops.secrets."modelscope.apiKey.opencode".path}}";
              };
              models = fromList [
                "Qwen/Qwen3.5-397B-A17B"
                "ZhipuAI/GLM-4.7-Flash"
                "ZhipuAI/GLM-5.1"
              ];
            };

          }

          (lib.optionalAttrs osConfig.services.ollama.enable {

            ollama = {
              name = "Ollama";
              options = {
                baseURL = "http://${osConfig.services.ollama.host}:${builtins.toString osConfig.services.ollama.port}/v1";
              };
              models = fromList osConfig.services.ollama.loadModels;
            };

            ollama_cloud = {
              name = "Ollama (Cloud)";
              options = {
                baseURL = "https://ollama.com/v1";
                apiKey = "{file:${config.sops.secrets."ollama.apiKey.opencode".path}}";
              };
              models = fromList (builtins.filter (x: builtins.match ".*:cloud$" x != null) osConfig.services.ollama.loadModels);
            };

          })

        ]);

      };

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

        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
          pkgs.makeWrapper
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
          deepseek = {
            api = "openai-completions";
            baseUrl = "https://api.deepseek.com";
            apiKey = cat_ config.sops.secrets."deepseek.apiKey.pi".path;
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

  };

}
