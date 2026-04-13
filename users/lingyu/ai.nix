{ config, lib, pkgs, ... } : {

  home.packages = with pkgs; [
    github-copilot-cli
  ];

  services.ollama = {
    enable = true;
    host = "localhost";
    port = 11434; 
  };
  
  programs.aichat = {
    enable = config.services.ollama.enable;
    package = pkgs.aichat;
    settings = {
      model = "ollama:deepseek-v3.2:cloud";
      clients = [
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://localhost:${builtins.toString config.services.ollama.port}/v1";
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
