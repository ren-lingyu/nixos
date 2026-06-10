{ config, pkgs, lib, ... } : {
  
  imports = [
    ./features
    ./users
    ./overlays
  ];
  
  options = {
    modules.base = {
      allowUnfreePredicateList = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [ "github-copilot-cli" ];
      };
    };
  };
  
  config = {

    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
    
    nixpkgs = {
      config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) config.modules.base.allowUnfreePredicateList;
    };
    
    environment = {
      enableAllTerminfo = lib.mkDefault true;
      systemPackages = with pkgs; [
        git
        vim
        curl
        wget
        gnutar
        gzip
      ];
    };
    
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      sharedModules = [
        ({ config, pkgs, lib, ... } : {
          config = {
            programs.fastfetch = {
              enable = lib.mkDefault true;
              package = lib.mkDefault pkgs.fastfetch;
              settings = lib.mkDefault {};
            };
            home.stateVersion = "26.05";
          };
        })
      ];
    };
    
  };
  
}
