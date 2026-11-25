{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  hasSystemShell =
    osConfig ? features.shell.bash.package
    && osConfig ? features.shell.zsh.package
    && osConfig ? programs.zsh.enable;
in
{
  options = {
    features.shell.enable = lib.mkEnableOption "Home Manager shell configuration";
  };

  config = lib.mkIf config.features.shell.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = hasSystemShell;
            message = "Home Manager Shell requires the system Shell package options and programs.zsh.enable.";
          }
        ];
      }
      (lib.mkIf hasSystemShell {
        programs.bash = {
          enable = !osConfig.programs.zsh.enable;
          package = osConfig.features.shell.bash.package;
          enableCompletion = true;
          shellAliases = { };
        };

        programs.zsh = {
          enable = osConfig.programs.zsh.enable;
          package = osConfig.features.shell.zsh.package;
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
      })
    ]
  );
}
