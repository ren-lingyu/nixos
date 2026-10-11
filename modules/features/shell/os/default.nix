{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.modules.features.shell;

in
{

  config = lib.mkIf cfg.enable {

    users = {
      defaultUserShell = (
        if (config.programs.zsh.enable == true) then
          (config.moduleInternals.features.shell.zsh.package)
        else
          (config.moduleInternals.features.shell.bash.package)
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
