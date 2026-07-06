{ config, osConfig, pkgs, lib, ... } : let

  cfg = osConfig.modules.features.editor;

in {

  config = lib.mkIf cfg.enable {
    
    programs.nixvim = {
      enable = cfg.neovim.enable;
      nixpkgs = {
        useGlobalPackages = true;
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
      package = pkgs.emacs-gtk;
    };

    services.emacs = {
      enable = config.programs.emacs.enable;
      package = pkgs.emacs-gtk;
      extraOptions = [ "--debug-init" ];
      defaultEditor = cfg.defaultEditor == "emacs";
      socketActivation = {
        enable = true;
      };
      startWithUserSession = false;
      client = {
        enable = false;
        arguments = ["-c"];
      };
    };
    
  };
  
}
