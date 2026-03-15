{ config, lib, pkgs, ... }:
{
  users = {
    defaultUserShell = pkgs.zsh;
  };
  
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableLsColors = true;
      autosuggestions = {
        enable = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      histSize = 10000;
      histFile = "$HOME/.zsh_history";
      ohMyZsh = {
        enable = true;
        package = pkgs.oh-my-zsh;
        plugins = [
          "z"
          "git"
        ];
        theme = "robbyrussell";
      };
    };
  };
}
