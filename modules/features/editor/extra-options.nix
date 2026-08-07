feature_ : { config, pkgs, lib, llib, ... } : {

  defaultEditor = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum [
      "vim"
      "neovim"
      "emacs"
    ]);
    default = null;
    example = "emacs";
    description = "Choose the default editor from Vim, Neovim, and Emacs.";
  };

  vim.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable Vim.";
  };

  neovim.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    example = true;
    description = "Whether to enable Neovim.";
  };

  emacs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable Emacs.";
    };
    programs.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.emacs-gtk;
      example = lib.literalExpression "pkgs.emacs-pgtk";
      description = "The Emacs package used by `programs.emacs`.";
    };
    services.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.emacs-gtk;
      example = lib.literalExpression "pkgs.emacs-pgtk";
      description = "The Emacs package used by `services.emacs`.";
    };
  };

  lem = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to enable Lem.";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.lem-webview;
      example = lib.literalExpression "pkgs.lem-webview";
      description = "The Lem package added in `home.packages`.";
    };
  };

}
