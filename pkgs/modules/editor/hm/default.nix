{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.features.editor;

in
{
  options.features.editor = {
    enable = lib.mkEnableOption "Home Manager editor configuration";
    defaultEditor = lib.mkOption {
      type = (import ../../../lib/types.nix { inherit lib; }).defaultEditor;
      default = null;
      description = "Default editor.";
    };
    vim.enable = lib.mkEnableOption "Vim";
    neovim.enable = lib.mkEnableOption "Neovim";
    emacs = {
      enable = lib.mkEnableOption "Emacs";
      programs.package = lib.mkPackageOption pkgs "emacs-gtk" { };
      services.package = lib.mkPackageOption pkgs "emacs-gtk" { };
    };
    lem = {
      enable = lib.mkEnableOption "Lem";
      package = lib.mkPackageOption pkgs "lem-webview" { };
    };
  };

  config = lib.mkIf config.features.editor.enable {
    home.packages = lib.optionals cfg.lem.enable [ cfg.lem.package ];

    programs.nixvim = {
      enable = cfg.neovim.enable;
      nixpkgs = {
        useGlobalPackages = true;
      };
      env = {
        TZ = "UTC0";
      };
      defaultEditor = cfg.defaultEditor == "neovim";
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      opts = {
        number = true;
        relativenumber = true;
        expandtab = true;
        tabstop = 2;
        shiftwidth = 2;
        softtabstop = 2;
        mouse = "a";
        ignorecase = true;
        smartcase = true;
        termguicolors = true;
        clipboard = "unnamedplus";
      };
      plugins = {
        lualine.enable = true;
        gitsigns.enable = true;
        which-key.enable = true;
        telescope.enable = true;
        web-devicons.enable = true;
        mini-icons.enable = true;
        cmp = {
          enable = true;
          autoEnableSources = true;
        };
        treesitter = {
          enable = true;
          autoLoad = true;
          nixvimInjections = true;
          highlight.enable = true;
          indent.enable = true;
          folding.enable = true;
          nixGrammars = true;
        };
        lsp = {
          enable = true;
          servers = {
            nixd.enable = true;
            bashls.enable = true;
            clangd.enable = true;
            gopls.enable = true;
            jdtls.enable = true;
            ts_ls.enable = true;
            pyright.enable = true;
            lua_ls.enable = true;
            marksman.enable = true;
            yamlls.enable = true;
          };
        };
        orgmode.enable = true;
      };
      colorschemes = {
        catppuccin = {
          enable = true;
          settings.flavour = "mocha";
        };
      };
    };

    programs.vim = {
      enable = cfg.vim.enable;
      package = pkgs.vim;
      defaultEditor = cfg.defaultEditor == "vim";
    };

    programs.emacs = {
      enable = cfg.emacs.enable;
      package = cfg.emacs.programs.package;
    };

    services.emacs = {
      enable = cfg.emacs.enable;
      package = cfg.emacs.services.package;
      extraOptions = [ "--debug-init" ];
      defaultEditor = cfg.defaultEditor == "emacs";
      socketActivation = {
        enable = true;
      };
      startWithUserSession = false;
      client = {
        enable = false;
        arguments = [ "-c" ];
      };
    };
  };
}
