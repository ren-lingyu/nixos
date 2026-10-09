{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let

  cfg = osConfig.modules.features.shell;

in
{

  config = lib.mkIf cfg.enable {

    programs.bash = {
      enable = !osConfig.programs.zsh.enable;
      package = cfg.bash.package;
      enableCompletion = true;
      shellAliases = { };
    };

    programs.zsh = {
      enable = osConfig.programs.zsh.enable;
      package = cfg.zsh.package;
      defaultKeymap = "emacs";
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };
      syntaxHighlighting = {
        enable = true;
      };
      history = {
        size = 1000;
        save = 1000;
        share = true;
        path = "$HOME/.zsh_history";
        append = true;
        extended = true;
        ignoreDups = true;
        ignoreAllDups = true;
        findNoDups = true;
      };
      initContent = lib.mkMerge [
        (lib.mkOrder 1000 (
          builtins.concatStringsSep "\n" [
            "function delete-char-or-kill-region {"
            "if [[ $REGION_ACTIVE -eq 1 ]]; then"
            "zle kill-region"
            "else"
            "zle delete-char"
            "fi"
            "}"
            "zle -N delete-char-or-kill-region"
            "bindkey '^[[3~' delete-char-or-kill-region"
            "export $(dbus-launch)"
          ]
        ))
      ];
      shellAliases = { };
      # 没有采用静态加载且暂时用不到插件功能故禁用 antidote
      antidote = {
        enable = false;
        package = pkgs.antidote;
        plugins = [
          "ohmyzsh/ohmyzsh path:lib kind:defer"
          "ohmyzsh/ohmyzsh path:plugins/git kind:defer"
          "romkatv/zsh-bench kind:defer"
        ];
        useFriendlyNames = true;
      };
    };

    programs.starship = {
      enable = true;
      package = pkgs.starship;
      enableBashIntegration = !osConfig.programs.zsh.enable;
      enableZshIntegration = osConfig.programs.zsh.enable;
      settings = {
        scan_timeout = 10000;
        add_newline = false;
        line_break.disabled = true;
      };
    };

  };

}
