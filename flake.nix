{
  
  description = "NixOS configuration";

  nixConfig = {
    auto-optimise-store = true;
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    extra-substituters = [
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
  
  inputs = {
    nixpkgs = {
      # url = "github:NixOS/nixpkgs/nixos-unstable";
      url = "git+https://github.com/NixOS/nixpkgs?ref=refs/heads/nixos-unstable&shallow=1";
      # url = "git+https://github.com/NixOS/nixpkgs?ref=refs/heads/nixos-unstable&rev=025c852a89be820b3117f604c8ace42e9b4caa08&shallow=1";
      # url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=refs/heads/nixos-unstable&shallow=1";
    };
    arcc-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager.git?ref=refs/heads/master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "git+https://github.com/Mic92/sops-nix.git?ref=refs/heads/master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      # the main branch of nixvim must be use in nixos-unstable
      url = "git+https://github.com/nix-community/nixvim.git?ref=refs/heads/main&shallow=1";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "git+https://github.com/nix-community/NixOS-WSL.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "git+https://github.com/nix-community/nixos-vscode-server.git?ref=refs/heads/master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "git+https://github.com/sodiboo/niri-flake.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-shell = {
      url = "git+https://github.com/noctalia-dev/noctalia-shell.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "git+https://github.com/gmodena/nix-flatpak.git?ref=refs/tags/latest&shallow=1";
    };
    emarccs = {
      url = "git+https://github.com/ren-lingyu/emarccs.git?ref=refs/heads/main&shallow=1";
    };
  };
  
  outputs = { self, ... }@inputs : {
    
    nixosModules = {

      base = { config, pkgs, lib, ... } : {
        imports = [
          inputs.home-manager.nixosModules.home-manager
        ];
        options = {
          # nixpkgs.config.allowUnfreePredicateList = lib.mkOption {
          #   type = lib.types.listOf str;
          #   default = [];
          #   example = [ "github-copilot-cli" ];
          # };
        };
        config = {
          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
          nixpkgs = {
            overlays = [
              (final: prev: {
                arcc = inputs.arcc-nixpkgs.packages."${prev.system}";
              })
            ];
            # config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) config.nixpkgs.config.allowUnfreePredicateList;
          };
          environment.systemPackages = with pkgs; [
            git
            vim
            curl
            wget
            gnutar
            gzip
          ];          
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            extraSpecialArgs = {
              inherit inputs;
            };
          };
        };
      };
      
      niri = { config, pkgs, lib, ... } : {
        imports = [
          inputs.sops-nix.nixosModules.sops
          ./modules/niri
        ];
        config = {     
          nixpkgs = {
            overlays = [
              inputs.niri-flake.overlays.niri
            ];
          };
          home-manager.sharedModules = [
            inputs.niri-flake.homeModules.niri
            inputs.noctalia-shell.homeModules.default
          ];
        };
      };
      
      secret = { config, pkgs, lib, ... } : {
        imports = [
          inputs.sops-nix.nixosModules.sops
          ./modules/secret
        ];
        config = {
          home-manager.sharedModules = [
            inputs.sops-nix.homeManagerModules.sops
          ];
        };
      };
      
      share = { config, pkgs, lib, ... } : {
        imports = [
          ./modules/cloud
          ./modules/texlive
          ./modules/font
          ./modules/shell
          ./modules/media
          ./modules/office
          ./modules/agent
        ];
      };
      
      user = {
        lingyu = { config, pkgs, lib, ... } : {
          imports = [
            ./modules/user
          ];
          config = {
            modules = {
              user = {
                enable = true;
                name = "lingyu";
                home = "/home/lingyu";
                uid = 1000;
              };
            };
            home-manager = {
              users."1000" = {
                imports = [
                  inputs.emarccs.homeManagerModules.default
                ];
              };
              sharedModules = [
                inputs.nixvim.homeModules.nixvim
              ];
            };
          };
        };
      };
      
      host = {
        wsl = { config, pkgs, lib, ... } : {
          imports = [
            inputs.nixos-wsl.nixosModules.default
            inputs.vscode-server.nixosModules.default
            ./modules/host/wsl
          ];
          config = {           
            nixpkgs.config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) [
              "github-copilot-cli"
            ];
          };
        };
        thinkbook = { config, pkgs, lib, ... } : {
          imports = [
            inputs.nix-flatpak.nixosModules.nix-flatpak
            ./modules/host/thinkbook
          ];
          config = {           
            nixpkgs.config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) [
              "github-copilot-cli"
              "microsoft-edge"
              "feishu"
              "libwemeetwrap"
              "wemeet"
              "wechat"
              "qq"
            ];
          };
        };
      };
      
    };
    
    nixosConfigurations = {
      nixos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.base
          self.nixosModules.share
          self.nixosModules.niri
          self.nixosModules.secret
          self.nixosModules.host.thinkbook
          self.nixosModules.user.lingyu
          {
            config = {
              modules = {
                cloud.enable = true;
                font.enable = true;
                media.enable = true;
                office.enable = true;
                shell.enable = true;
                texlive.enable = true;
                agent.enable = true;
                secret = {
                  enable = true;
                  hm.enable = true;
                  os.enable = true;
                };
                niri = {
                  enable = true;
                  greeter.enable = true;
                  monitor = {
                    name = "eDP-1";
                    width = 3072;
                    height = 1920;
                  };
                  noctalia-shell.enable = true;
                  waybar.enable = false;
                };
              };
            };
          }
        ];
      };
      nixos-wsl = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.base
          self.nixosModules.share
          self.nixosModules.secret
          self.nixosModules.host.wsl
          self.nixosModules.user.lingyu
          {
            config = {
              modules = {
                cloud.enable = true;
                font.enable = true;
                media.enable = false;
                office.enable = false;
                shell.enable = true;
                texlive.enable = true;
                secret = {
                  enable = true;
                  hm.enable = true;
                  os.enable = true;
                };
              };
            };
          }
        ];
      };
    };
    
  };
  
}
