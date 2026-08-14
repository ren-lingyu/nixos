{ config, lib, pkgs, osConfig, ... } : let

  cfg = osConfig.modules.features.agent;

in {

  config = lib.mkIf cfg.enable {

    programs.opencode = {

      enable = true;
      package = pkgs.opencode;
      enableMcpIntegration = false;
      extraPackages = [];

      settings = {

        permission = "ask";
        model = "deepseek/deepseek-v4-pro";
        small_model = "deepseek/deepseek-v4-flash";
        autoupdate = false;

        enabled_providers = builtins.concatLists [
          [ "deepseek" ]
        ];

        provider = (lib.mergeAttrsList [

          {

            deepseek = {
              name = "DeepSeek";
              options = {
                baseURL = "https://api.deepseek.com";
                apiKey = "{file:${config.sops.secrets."deepseek.apiKey.opencode".path}}";
              };
              models = {
                deepseek-v4-pro = {
                  name = "DeepSeek-V4-Pro";
                  limit = {
                    context = 1000000;
                    output = 384000;
                  };
                };
                deepseek-v4-flash = {
                  name = "DeepSeek-V4-Flash";
                  limit = {
                    context = 1000000;
                    output = 384000;
                  };
                };
              };
            };

          }

        ]);

      };

      context = ./context.md;
      agents = {};
      commands = {};
      skills = ./skills;
      tools = {};
      themes = {};
      tui = {};

      web = {
        enable = false;
        extraArgs = [];
        environmentFile = null;
      };

    };

    programs.pi-coding-agent = let

      final_ = (prev_ : let

        prevExeOutput_ = lib.getBin prev_;
        prevExeOutputVar_ = "$" + (prevExeOutput_.outputName or "out");
        prevExePath_ = lib.getExe prev_;
        prevExeRelPath_ = (
          if lib.hasPrefix "${prevExeOutput_}/" prevExePath_
          then lib.removePrefix "${prevExeOutput_}" prevExePath_
          else builtins.throw "pi-coding-agent executable path ${prevExePath_} is not under ${prevExeOutput_}"
        );

      in prev_.overrideAttrs (oldAttrs: {

        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
          pkgs.makeWrapper
        ];
        postFixup = builtins.concatStringsSep "\n" [
          (oldAttrs.postFixup or "")
          ''wrapProgram "${prevExeOutputVar_}${prevExeRelPath_}" --set PI_OFFLINE 1''
        ];

      })) pkgs.pi-coding-agent;

    in {

      enable = true;
      package = final_;

      extraPackages = with pkgs; [
        fd
        ripgrep
        convco
      ];

      context = ./context.md;

      models = let
        cat_ = x_ : "!${lib.getExe' pkgs.coreutils "cat"} ${lib.escapeShellArg x_}";
      in {
        providers = {
          deepseek = {
            api = "openai-completions";
            baseUrl = "https://api.deepseek.com";
            apiKey = cat_ config.sops.secrets."deepseek.apiKey.pi".path;
          };
        };
      };

      settings = {
        defaultProjectTrust = "ask";
        enableInstallTelemetry = false;
        skills = [
          "${./skills}"
        ];
      };

    };

    programs.codex = {
      enable = true;
      package = pkgs.codex;
      context = ./context.md;
      skills = ./skills;
    };

    programs.github-copilot-cli = {
      enable = true;
      package = pkgs.github-copilot-cli;
      context = ./context.md;
      skills = ./skills;
    };

  };

}
