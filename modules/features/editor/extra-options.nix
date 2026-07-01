feature_ : { config, pkgs, lib, ... } : {
  
  defaultEditor = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [
      "vim"
      "neovim"
      "emacs"
    ]);
    default = null;
    example = "emacs";
    description = "Choose the default editor from vim, neovim and emacs.";
  };
  
  vim.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable vim.";
  };
  
  neovim.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable the neovim.";
  };
  
  emacs.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable the emacs.";
  };
  
}
