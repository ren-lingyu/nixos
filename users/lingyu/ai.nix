{ config, lib, pkgs, ... } : {

  home.packages = with pkgs; [
    github-copilot-cli
  ];

  programs.aichat = {
    enable = config.services.ollama.enable;
    package = pkgs.aichat;
    settings = {
      model = "ollama:deepseek-v3.2:cloud";
      clients = [
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://localhost:11434/v1";
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
