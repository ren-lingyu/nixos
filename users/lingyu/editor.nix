{ config, lib, pkgs, nixvim, ... } : {

  imports = [
    nixvim.homeModules.nixvim
  ];
  
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
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
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
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
    enable = false;
    package = pkgs.vim;
    defaultEditor = false;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
    extraOptions = [ "--debug-init" ];
    defaultEditor = false;
    socketActivation = {
      enable = true;
    };
    startWithUserSession = false;
    client = {
      enable = false;
      arguments = ["-c"];
    };
  };

}
