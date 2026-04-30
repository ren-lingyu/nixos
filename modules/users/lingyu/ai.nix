{ config, lib, pkgs, osConfig, ... } : {

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

}
