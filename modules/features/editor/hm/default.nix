{ config, osConfig, pkgs, lib, ... } : {

  config = lib.mkIf osConfig.modules.features.editor.enable {
    
  programs.nixvim = {
    enable = osConfig.modules.features.editor.neovim.enable;
    defaultEditor = osConfig.modules.features.editor.defaultEditor == "neovim";
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
    enable = osConfig.modules.features.editor.vim.enable;
    package = pkgs.vim;
    defaultEditor = osConfig.modules.features.editor.defaultEditor == "vim";
  };

  programs.emacs = {
    enable = osConfig.modules.features.editor.emacs.enable;
    package = pkgs.emacs-gtk;
  };

  services.emacs = {
    enable = config.programs.emacs.enable;
    package = pkgs.emacs-gtk;
    extraOptions = [ "--debug-init" ];
    defaultEditor = osConfig.modules.features.editor.defaultEditor == "emacs";
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
