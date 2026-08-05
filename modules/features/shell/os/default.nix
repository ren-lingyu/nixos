{ config, lib, pkgs, ... } : let

  cfg = config.modules.features.shell;

in {

  config = lib.mkIf cfg.enable {

    users = {
      defaultUserShell = (
        if (config.programs.zsh.enable == true)
        then (
          cfg.zsh.package
        )
        else (
          cfg.bash.package
        )
      );
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
