{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.features.shell = {
    bashPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.bashInteractive;
      description = "Bash package shared with Home Manager.";
    };
    zshPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.zsh;
      description = "Zsh package shared with Home Manager.";
    };
  };

  config = {
    users = {
      defaultUserShell = (
        if (config.programs.zsh.enable == true) then
          (config.features.shell.zshPackage)
        else
          (config.features.shell.bashPackage)
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
