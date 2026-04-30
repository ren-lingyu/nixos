{ config, lib, pkgs, ... } : {

  home.packages = with pkgs; [
    git-filter-repo
  ];

  programs.ssh.matchBlocks = lib.mkIf ( config.programs.ssh.enable && config.programs.git.enable ) {
    "github.com" = {
      hostname = "github.com";
      # hostname = "ssh.github.com";
      port = 22;
      # port = 443;
      user = "git";
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
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

}
