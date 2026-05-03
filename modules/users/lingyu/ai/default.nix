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
          [ "deepseek" ]
          (lib.optionals osConfig.services.ollama.enable [ "ollama_local" "ollama_cloud" ])
        ];
        
        provider = {
          
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

          ollama_local = {
            name = "Ollama (Local)";
            options = {
              baseURL = "http://${osConfig.services.ollama.host}:${builtins.toString osConfig.services.ollama.port}/v1";
            };
            models = (
              builtins.listToAttrs (
                map (x: {
                  name = builtins.toString x;
                  value = {
                    name = builtins.toString x;
                  };
                }) osConfig.services.ollama.loadModels
              )
            );
          };

          ollama_cloud = {
            name = "Ollama (Cloud)";
            options = {
              apiKey = "{file:${config.sops.secrets."ollama.apiKey.opencode".path}}";
            };
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
