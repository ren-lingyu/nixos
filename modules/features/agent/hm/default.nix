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

in
{

  config = lib.mkIf cfg.enable {

    home =
      let
        packages_ = lib.optionals config.programs.git.enable (
          with pkgs;
          [
            git-agent-workflow
            git-maintenance
          ]
        );
      in
      {
        packages = packages_;
        file = {
          ".agents/AGENTS.md" = {
            enable = true;
            text = context_;
          };
          ".agents/skills" = {
            enable = true;
            source = pkgs.buildEnv {
              name = "agents-skills";
              paths = (builtins.map (package_: "${package_}/share/skills/${package_.pname}") packages_);
              checkCollisionContents = false;
            };
            recursive = true;
          };
        };
      };

    programs.opencode = {

      enable = true;
      package = pkgs.opencode;
      enableMcpIntegration = false;
      extraPackages = [ ];

      settings = lib.mergeAttrsList [
        (lib.optionalAttrs mif.opencode.providers.deepseek.enable {
          model = "deepseek/deepseek-v4-pro";
          small_model = "deepseek/deepseek-v4-flash";
        })
        {

          permission = "ask";
          autoupdate = false;

          enabled_providers = (
            builtins.attrNames (lib.filterAttrs (name_: value_: value_.enable == true) mif.opencode.providers)
          );

          provider = {

            deepseek = lib.mkIf mif.opencode.providers.deepseek.enable {
              name = "DeepSeek";
              options = {
                baseURL = "https://api.deepseek.com";
                apiKey = "{file:${mif.opencode.providers.deepseek.apiKey}}";
              };
            };

          };

        }
      ];

      context = context_;
      agents = { };
      commands = { };
      tools = { };
      themes = { };
      tui = { };

      web = {
        enable = false;
        extraArgs = [ ];
        environmentFile = null;
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
