{ config, lib, pkgs, ... } : {

  imports = [
    ./editor.nix
    ./shell.nix
    ./terminal.nix
    ./keyring.nix
  ];
  
  home = {
    username = "lingyu";
    homeDirectory = "/home/lingyu";
    packages = with pkgs; (builtins.concatLists [
      [ gh git-filter-repo github-copilot-cli ]
      [ jq ripgrep unzip trash-cli tree ]
      [ htop pciutils tcpdump mtr nmap netcat socat dnsutils ]
      [ xclock xeyes xclip ]
      [ python3 gnumake ]
      [ rclone ]
      [ chafa ]
      [ vulkan-tools ]
      [ adwaita-icon-theme xcursor-themes ]
    ]);
    sessionVariables = {
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

  systemd = {
    user = {
      sessionVariables = config.home.sessionVariables;
    };
  };

  programs.direnv = {
    enable = true;
    package = pkgs.direnv;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        # hostname = "ssh.github.com";
        port = 22;
        # port = 443;
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
      core.editor = "vim";
      init.defaultBranch = "main";
      commit.gpgSign = true;
      signing.signByDefault = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
    };
    ignores = [
      "NUL"
      "*~"
      "*#"
      "*#*"
      "*:Zone.Identifier"
    ];
  };

  programs.zathura = {
    enable = true;
    package = pkgs.zathura;
    options = {};
    mappings = {};
  };

  xdg = {
    autostart.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
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
