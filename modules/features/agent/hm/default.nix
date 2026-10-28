{
  options,
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let

  cfg = osConfig.modules.features.agent;

  mifOptions_ = options.moduleInterfaces.features.agent;

  rawMif_ = config.moduleInterfaces.features.agent;

  normalizeProvider_ =
    agent_: provider_: providerConfig_:
    lib.mergeAttrsList [
      (builtins.removeAttrs providerConfig_ [ "enable" ])
      {
        enable =
          if mifOptions_.${agent_}.providers.${provider_}.enable.isDefined then
            providerConfig_.enable
          else
            false;
      }
    ];

  mif = lib.mapAttrs (
    agent_: agentConfig_:
    lib.mergeAttrsList [
      (builtins.removeAttrs agentConfig_ [ "providers" ])
      {
        providers = lib.mapAttrs (provider_: normalizeProvider_ agent_ provider_) agentConfig_.providers;
      }
    ]
  ) rawMif_;

  context_ = import ./context {
    inherit pkgs lib;
    git = (if config.programs.git.package == null then pkgs.git else config.programs.git.package);
    git-agent-workflow = pkgs.git-agent-workflow;
  };

  packagesWithSkills_ = lib.optionals config.programs.git.enable (
    with pkgs;
    [
      git-agent-workflow
      git-maintenance
    ]
  );

  skills_ = lib.listToAttrs (
    map (p_: {
      name = p_.pname;
      value = "${p_}/share/skills/${p_.pname}";
    }) packagesWithSkills_
  );

in
{
  config = lib.mkIf cfg.enable {
    home = {
      packages = builtins.concatLists [ packagesWithSkills_ ];
      file = {
        ".agents/AGENTS.md" = {
          enable = true;
          text = context_;
        };
        ".agents/skills" = {
          enable = true;
          source = pkgs.linkFarm "agents-skills" skills_;
          recursive = true;
        };
      };
    };

    programs.pi-coding-agent = {
      enable = true;
      package = pkgs.pi-coding-agent;

      extraPackages = with pkgs; [
        fd
        ripgrep
        convco
        wl-clipboard
        xclip
      ];

      context = context_;

      models =
        let
          cat_ = x_: "!${lib.getExe' pkgs.coreutils "cat"} ${lib.escapeShellArg x_}";
        in
        {
          providers = {
            deepseek = lib.mkIf mif.pi.providers.deepseek.enable {
              api = "openai-completions";
              baseUrl = "https://api.deepseek.com";
              apiKey = cat_ mif.pi.providers.deepseek.apiKey;
            };
          };
        };

      settings = {
        defaultProjectTrust = "ask";
        enableInstallTelemetry = false;
        packages = [
          "${pkgs.piPackages.pi-mono-context}"
          "${pkgs.piPackages.pi-mono-web-search}"
          "${pkgs.piPackages.pi-agentic-search}"
          "${pkgs.piPackages.pi-workspace-history}"
        ];
      };
    };

    programs.codex = {
      enable = true;
      package = pkgs.codex;
      context = context_;
    };

    programs.github-copilot-cli = {
      enable = true;
      package = pkgs.github-copilot-cli;
      context = context_;
      skills = skills_;
    };

    assertions = builtins.concatLists (
      lib.mapAttrsToList (
        agent_: agentConfig_:
        lib.mapAttrsToList (provider_: providerConfig_: {
          assertion = (
            builtins.any (x_: x_) [
              (!providerConfig_.enable)
              mifOptions_.${agent_}.providers.${provider_}.apiKey.isDefined
            ]
          );
          message = "`moduleInterfaces.features.agent.${agent_}.providers.${provider_}.enable = true` requires `moduleInterfaces.features.agent.${agent_}.providers.${provider_}.apiKey` to be defined.";
        }) agentConfig_.providers
      ) mif
    );
  };
}
