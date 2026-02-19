{ config, pkgs, ... }:

{
  home.username = "lingyu";
  home.homeDirectory = "/home/lingyu";

  home.packages = with pkgs;[
  		git
		gh
		git-filter-repo
  		curl
		wget
		ripgrep
		htop
		unzip
		gnutar
		trash-cli
		tree
		gnumake
		jq
		dbus
		rclone
		fuse
		fuse3
		ghostscript
		xclip
		chafa
		gcc
		noto-fonts
		noto-fonts-cjk-sans
		noto-fonts-color-emoji
		dejavu_fontsEnv
		zenity
		fcitx5
		fcitx5-gtk
    		qt6Packages.fcitx5-configtool
    		qt6Packages.fcitx5-qt
    		qt6Packages.fcitx5-chinese-addons
		openssh
		gnupg
		pinentry-tty
		emacs-gtk
		vim
  ];

  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx5";
    QT_IM_MODULE = "fcitx5";
    XMODIFIERS = "@im=fcitx5";
    SDL_IM_MODULE = "fcitx5";
    GLFW_IM_MODULE = "ibus";
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

  # home.file.".config/starship-simple.toml".text = builtins.readFile ./starship-simple.toml;

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
    bashrcExtra = builtins.readFile ./bashrc-early.sh;
    # initExtra = builtins.readFile ./bashrc-late.sh;
    shellAliases = {};
  };

  home.file = {
    ".local/bin/org" = {
      text = builtins.readFile ./org.sh;
      executable = true;
    };
    ".local/bin/ssha" = {
      text = builtins.readFile ./ssha.sh;
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