{ config, lib, pkgs, ... }:

{
  
  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama;
      host = "127.0.0.1";
      port = 11434; 
      loadModels = [
        "gemma3n:e4b"
	      "qwen3-coder-next:cloud"
        "qwen3.5:cloud"
        "deepseek-v3.2:cloud"
      ];
      syncModels = true;
    };
  };
  
}
