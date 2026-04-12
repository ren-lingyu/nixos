{ config, lib, pkgs, nixvim, ... } : {

  imports = [
    nixvim.homeModules.nixvim
  ];
  
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimdiffAlias = true;
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
