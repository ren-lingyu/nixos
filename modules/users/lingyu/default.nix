{ config, lib, pkgs, ... } : {

  imports = [
    ./editor.nix
    ./shell.nix
    ./terminal.nix
    ./keyring.nix
    ./ai.nix
    ./git.nix
    ./langs.nix
  ];
  
  home = {
    username = "lingyu";
    homeDirectory = "/home/lingyu";
    packages = with pkgs; (builtins.concatLists [
      [ jq ripgrep unzip trash-cli tree ]
      [ htop pciutils tcpdump mtr nmap netcat socat dnsutils ]
      [ xclock xeyes xclip ]
      [ gnumake ]
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
      "${config.xdg.binHome}"
    ];
    file = {
      ".local/bin/nut" = {
        enable = true;
        source = ./.local/bin/nut.sh;
        target = ".local/bin/nut";
        executable = true;
      };
      ".local/bin/org" = {
        enable = true;
        source = ./.local/bin/org.sh;
        target = ".local/bin/org";
        executable = true;
      };
      ".local/bin/ssha" = {
        enable = true;
        source = ./.local/bin/ssha.sh;
        target = ".local/bin/ssha";
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

  programs.zathura = {
    enable = true;
    package = pkgs.zathura;
    options = {};
    mappings = {};
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    binHome = "${config.home.homeDirectory}/.local/bin";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
    autostart.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
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
