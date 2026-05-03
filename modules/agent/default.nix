{ config, lib, pkgs, osConfig, ... } : {

  config = {

    home.packages = with pkgs; [
      github-copilot-cli
    ];
    
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
        autoupdate = false;
        
        enabled_providers = builtins.concatLists [
          [ "deepseek" "modelscope" ]
          (lib.optionals osConfig.services.ollama.enable [ "ollama" "ollama_cloud" ])
        ];
        
        provider = let
          
          fromList = list : builtins.listToAttrs (
            map (x: {
              name = builtins.toString x;
              value = {
                name = builtins.toString x;
              };
            }) list
          );
            
        in {
          
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
                  context = 840000;
                  output = 128000;
                };
              };
            };
          };

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
          
        };
        
      };
      
      agents = {};
      tools = {};
      commands = {
        commit-message = builtins.readFile ./commands/commit-message.md;
      };
      skills = {};
      themes = {};
      tui = {};
      context = "";
      
      web = {
        enable = false;
        extraArgs = [];
        environmentFile = null;
      };
      
    };

  };
  
}
