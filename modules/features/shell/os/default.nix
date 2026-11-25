{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    features.shell = {
      enable = lib.mkEnableOption "system shell configuration";
      bash.package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = pkgs.bashInteractive;
        description = "Bash package shared with Home Manager.";
      };
      zsh.package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        default = pkgs.zsh;
        description = "Zsh package shared with Home Manager.";
      };
    };
  };

  config = lib.mkIf config.features.shell.enable {
    users = {
      defaultUserShell = (
        if (config.programs.zsh.enable == true) then
          (config.features.shell.zsh.package)
        else
          (config.features.shell.bash.package)
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
