{ config, pkgs, ... }:

{
  home.username = "lingyu";
  home.homeDirectory = "/home/lingyu";

  home.packages = with pkgs;[
    gh
    git-filter-repo
    trash-cli
    xclip
    chafa
    dejavu_fontsEnv
    emacs-pgtk
  ];

  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
    QT_QPA_PLATFORM = "xcb";
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
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

  programs.starship = {
    enable = true;
    settings = {
      scan_timeout = 1000;
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
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

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = builtins.readFile ./.bashrc/early.sh;
    # initExtra = builtins.readFile ./.bashrc/late.sh;
    shellAliases = {};
  };

  home.file = {
    ".config/fcitx5/profile" = {
      source = ./.config/fcitx5/profile;
      force = true;
    };
    ".local/bin/org" = {
      text = builtins.readFile ./.local/bin/org.sh;
      executable = true;
    };
    ".local/bin/ssha" = {
      text = builtins.readFile ./.local/bin/ssha.sh;
      executable = true;
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