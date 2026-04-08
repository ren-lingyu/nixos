{ config, lib, pkgs, ... }:
{
  home = {
    username = "lingyu";
    homeDirectory = "/home/lingyu";
    packages = with pkgs;[
      gh
      jq
      rclone
      git-filter-repo
      trash-cli
      chafa
      dejavu_fontsEnv
      emacs-gtk
      adwaita-icon-theme
      xcursor-themes
      xclip
      aichat
      ollama
      github-copilot-cli
      python3
      ripgrep
      htop
      tree
      ghostscript
      tcpdump
      mtr
      nmap
      netcat
      dig
      xclock
      xeyes
      socat
      zathura
      zotero
      calibre
      xournalpp
    ];
    sessionVariables = {
      # GTK_IM_MODULE = "fcitx";
      # QT_IM_MODULE = "fcitx";
      # XMODIFIERS = "@im=fcitx";
      # SDL_IM_MODULE = "fcitx";
      # GLFW_IM_MODULE = "ibus";
      QT_QPA_PLATFORM = "xcb";
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";
      GPG_TTY = "$(tty)";
      TEXINPUTS = "$HOME/org/texmf//:";
      BIBINPUTS = "$HOME/org/texmf//:";
      BSTINPUTS = "$HOME/org/texmf//:";
    };
    sessionPath = [
      "$HOME/.local/bin"
    ];
    file = {
      ".local/bin/nutstore" = {
        enable = false;
        source = ./.local/bin/nutstore.sh;
        executable = true;
      };
      ".local/bin/org" = {
        enable = true;
        source = ./.local/bin/org.sh;
        executable = true;
      };
      ".local/bin/ssha" = {
        enable = true;
        source = ./.local/bin/ssha.sh;
        executable = true;
      };
    };
  };

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
      # (lib.mkOrder 500 (lib.concatStringsSep "\n" [
      #   "if [[ -r \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\" ]]; then"
      #   "source \"\${XDG_CACHE_HOME:-\$HOME/.cache}/p10k-instant-prompt-\${(%):-%n}.zsh\""
      #   "fi"
      # ]))
      (lib.mkOrder 1000 (lib.concatStringsSep "\n" [
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
  
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # "github.com" = {
      #   hostname = "ssh.github.com";
      #   port = 443;
      #   user = "git";
      #   serverAliveInterval = 60;
      #   serverAliveCountMax = 3;
      # };
      "github.com" = {
        hostname = "github.com";
        port = 22;
        user = "git";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
      "*" = {
        forwardAgent = false;
      	serverAliveInterval = 0;
      	serverAliveCountMax = 3;
      	compression = false;
      	addKeysToAgent = "no";
      	hashKnownHosts = false;
      	userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
      	controlMaster = "no";
      	controlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
      	controlPersist = "no";
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "ren-lingyu";
        email = "Ren_Lingyu@outlook.com";
	      signingkey = "65F85A2624D239F0";
      };
      core = {
        editor = "emacs -Q -nw";
      };
      init = {
        defaultBranch = "main";
      };
      commit = {
        gpgSign = true;
      };
      signing = {
	      signByDefault = true;
      };
      gpg = {
        program = "${pkgs.gnupg}/bin/gpg";
      };
    };
    ignores = [
      "NUL"
      "*~"
      "*#"
      "*#*"
      "*:Zone.Identifier"
    ];
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.aichat = {
    enable = true;
    package = pkgs.aichat;
    settings = {
      model = "ollama:deepseek-v3.2:cloud";
      clients = [
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://localhost:11434/v1";
          models = [
            {
              name = "deepseek-v3.2:cloud";
              supports_function_calling = false;
              supports_vision = false;
            }
          ];
        }
      ];
    };
  };

  programs.zathura = {
    enable = true;
    package = pkgs.zathura;
    options = {};
    mappings = {};
  };

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
    };
  };

  systemd = {
    user = {
      sessionVariables = config.home.sessionVariables;
    };
  };
  
  services = {
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-tty;
    };
    emacs = {
      enable = true;
      package = pkgs.emacs-gtk;
      extraOptions = ["--debug-init"];
      defaultEditor = false;
      socketActivation = {
        enable = true;
      };
      startWithUserSession = false;
      client = {
        enable = false;
        arguments = ["-c"];
      };
    };
  };
  
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";
}
