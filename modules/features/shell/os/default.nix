{ config, lib, pkgs, ... } : {

  config = lib.mkIf config.modules.features.shell.enable {

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
        histSize = 1000;
        histFile = "$HOME/.zsh_history";
      };
    };

  };

}
