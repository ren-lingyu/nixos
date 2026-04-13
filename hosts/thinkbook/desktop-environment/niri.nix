{ config, lib, pkgs, ... } : {

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    useNautilus = true;
  };
  
}
