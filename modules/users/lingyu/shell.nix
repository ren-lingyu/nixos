{ config, lib, pkgs, ... } : {

  programs.bash = {
    enable = false;
    enableCompletion = true;
    shellAliases = {};
  };

  programs.zsh = {
    enable = true;
    package = pkgs.zsh;
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
      # (lib.mkOrder 500 (builtins.concatStringsSep "\n" [
      #   "if [[ -r \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then"
      #   "source \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\""
      #   "fi"
      # ]))
      (lib.mkOrder 1000 (builtins.concatStringsSep "\n" [
        # "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh"
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
      ]))
    ];
    shellAliases = {};
    # plugins = [
    #   {
    #     name = "powerlevel10k";
    #     src = pkgs.zsh-powerlevel10k;
    #     file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    #   }
    # ];
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
    enableZshIntegration = true;
    settings = {
      scan_timeout = 10000;
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

}
