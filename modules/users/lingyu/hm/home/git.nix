{ config, lib, pkgs, ... } : {

  home.packages = with pkgs; [
    git-filter-repo
  ];

  programs.ssh.settings = lib.mkIf (builtins.all
    (x_ : x_)
    [
      config.programs.ssh.enable
      config.programs.git.enable
    ]
  ) {
    "github.com" = {
      # hostname = "github.com";
      hostname = "ssh.github.com";
      # port = 22;
      port = 443;
      user = "git";
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
    };
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    signing = {
      key = "65F85A2624D239F0!";
      format = "openpgp";
      signer = (lib.getExe' pkgs.gnupg "gpg");
      signByDefault = true;
    };
    settings = {
      user = {
        name = "ren-lingyu";
        email = "Ren_Lingyu@outlook.com";
      };
      core.editor = "vim";
      init.defaultBranch = "main";
      gpg.program = "${lib.getExe' pkgs.gnupg "gpg"}";
      alias = {
        ipv4 = ''!git -c core.sshCommand="ssh -4"'';
      };
    } // (lib.optionalAttrs config.programs.difftastic.git.enable {
      difftool.prompt = false;
      pager.difftool = true;
    });
    ignores = [
      "NUL"
      "*~"
      "*#"
      "*#*"
      "*:Zone.Identifier"
    ];
  };

  programs.gh = {
    enable = true;
    package = pkgs.gh;
    gitCredentialHelper = {
      enable = true;
      hosts = [
        "https://github.com"
        "https://gist.github.com"
      ];
    };
    settings = {
      git_protocol = "https";
      editor = "";
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      pager = "";
      http_unix_socket = "";
      browser = "";
      color_labels = "disabled";
      accessible_colors = "disabled";
      accessible_prompter = "disabled";
      spinner = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };

  programs.difftastic = {
    enable = true;
    package = pkgs.difftastic;
    git = {
      enable = true;
      mode = "difftool";
    };
    options = {
      background = "dark";
      color = "always";
      display = "side-by-side";
      context = 3;
      tab-width = 4;
    };
  };

}
