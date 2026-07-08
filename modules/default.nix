{ config, pkgs, lib, ... } : {
  
  imports = [
    ./hosts
    ./users
    ./features
    ./overlays
  ];
  
  options = {
    modules.base = {
      allowUnfreePredicateList = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [ "github-copilot-cli" ];
      };
      createXdgUserDirectories = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to enable and create xdg user directories.";
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
        ({ config, osConfig, pkgs, lib, ... } : {
          config = {
            programs.fastfetch = {
              enable = lib.mkDefault true;
              package = lib.mkDefault pkgs.fastfetch;
              settings = lib.mkDefault {};
            };
            xdg = {
              enable = true;
              cacheHome = "${config.home.homeDirectory}/.cache";
              configHome = "${config.home.homeDirectory}/.config";
              binHome = "${config.home.homeDirectory}/.local/bin";
              dataHome = "${config.home.homeDirectory}/.local/share";
              stateHome = "${config.home.homeDirectory}/.local/state";
              userDirs = {
                enable = lib.mkForce osConfig.modules.base.createXdgUserDirectories;
                createDirectories = lib.mkForce osConfig.modules.base.createXdgUserDirectories;
                package = pkgs.xdg-user-dirs;
                desktop = "${config.home.homeDirectory}/Desktop";
                download = "${config.home.homeDirectory}/Downloads";
                documents = "${config.home.homeDirectory}/Documents";
                pictures = "${config.home.homeDirectory}/Pictures";
                videos = "${config.home.homeDirectory}/Videos";
                music = "${config.home.homeDirectory}/Music";
                templates = "${config.home.homeDirectory}/Templates";
                projects = "${config.home.homeDirectory}/Projects";
                publicShare = "${config.home.homeDirectory}/Public";
              };
            };
            home = {
              stateVersion = "26.05";
              preferXdgDirectories = config.xdg.enable;
            };
          };
        })
      ];
    };
    
  };
  
}
