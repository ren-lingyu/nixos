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
    self-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
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
    niri-flake = {
      url = "git+https://github.com/sodiboo/niri-flake.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "git+https://github.com/noctalia-dev/noctalia.git?ref=refs/tags/v4.7.7&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "git+https://github.com/gmodena/nix-flatpak.git?ref=refs/tags/latest&shallow=1";
    };
    emarccs = {
      url = "git+https://github.com/ren-lingyu/emarccs.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixos-anywhere = {
      url = "git+https://github.com/nix-community/nixos-anywhere.git?ref=refs/heads/main&shallow=1";
    };
    disko = {
      # url = "git+https://github.com/nix-community/disko.git?ref=refs/heads/master&shallow=1";
      follows = "nixos-anywhere/disko";
    };
  };
  
  outputs = { self, ... }@inputs : inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    
    systems = [
      "x86_64-linux"
    ];
    
    flake = {
      
      modules = {
        
        base = { config, pkgs, lib, ... } : {
          imports = [
            inputs.home-manager.nixosModules.home-manager
            ./modules
          ];
          config = {
            nixpkgs = {
              overlays = [
                inputs.self-nixpkgs.overlays.default
                inputs.emarccs.overlays.default
              ];
            };
            home-manager = {
              sharedModules = [
                inputs.self-nixpkgs.homeManagerModules.default
              ];
              extraSpecialArgs = {
                inherit inputs;
              };
            };
          };
        };
        
        features = {
          niri = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              inputs.sops-nix.nixosModules.sops
              ./modules/features/niri
            ];
            config = {
              nixpkgs = {
                overlays = [
                  inputs.niri-flake.overlays.niri
                ];
              };
              home-manager.sharedModules = [
                inputs.niri-flake.homeModules.niri
                inputs.noctalia.homeModules.default
              ];
            };
          };
          secret = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              inputs.sops-nix.nixosModules.sops
              ./modules/features/secret
            ];
            config = {
              home-manager.sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
            };
          };
          editor = { config, pkgs, lib, ... } : {
            imports = [
              ./modules/features/editor
            ];
            config = {
              home-manager.sharedModules = [
                inputs.nixvim.homeModules.nixvim
              ];
            };
          };
          share = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              ./modules/features/shell
              ./modules/features/font
              ./modules/features/texlive
              ./modules/features/media
              ./modules/features/office
              ./modules/features/remote
              ./modules/features/agent
              ./modules/features/proxy
              ./modules/features/greeter
              ./modules/features/x11-session
            ];
          };
        };
        
        users = {
          lingyu = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
            ];
            config = {
              modules.users = {
                "1000" = {
                  enable = true;
                  uid = 1000;
                  username = "lingyu";
                  home = {
                    enable = true;
                    directory = "/home/lingyu";
                    manager = {
                      enable = true;
                      source = "./lingyu";
                    };
                  };
                };
              };
            };
          };
          lingyu-minimal = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
            ];
            config = {
              modules.users = {
                "1000" = {
                  enable = true;
                  uid = 1000;
                  username = "lingyu";
                  home = {
                    enable = true;
                    directory = "/home/lingyu";
                    manager = {
                      enable = true;
                      source = null;
                    };
                  };
                };
              };
            };
          };
        };
        
        hosts = {
          wsl = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              inputs.nixos-wsl.nixosModules.default
              ./modules/hosts/wsl
            ];
          };
          thinkbook = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              inputs.nix-flatpak.nixosModules.nix-flatpak
              ./modules/hosts/thinkbook
            ];
            config.modules = {
              hosts.thinkbook = {
                packageGroups.tencent.enable = false;
                flatpak.enable = true;
              };
              overlays = {
                tencent.enable = false;
              };
            };
          };
          aliyun = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              inputs.disko.nixosModules.disko
              ./modules/hosts/aliyun
            ];
          };
        };
        
      };
      
      nixosConfigurations = {
        
        nixos = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.modules.features.share
            self.modules.features.editor
            self.modules.features.niri
            self.modules.features.secret
            self.modules.hosts.thinkbook
            self.modules.users.lingyu
            ({ config, pkgs, lib, ... } : {
              config = {
                modules = {
                  base = {
                    allowUnfreePredicateList = [
                      "github-copilot-cli"
                      "microsoft-edge"
                      "feishu"
                      "libwemeetwrap"
                      "wemeet"
                      "wechat"
                      "qq"
                      "zoom"
                    ];
                    createXdgUserDirectories = true;
                  };
                  features = {
                    shell.enable = true;
                    font.enable = true;
                    texlive.enable = true;
                    office.enable = true;
                    media.enable = true;
                    remote.enable = true;
                    agent.enable = true;
                    secret.enable = true;
                    proxy = {
                      enable = true;
                      clash-verge.enable = true;
                      throne.enable = true;
                    };
                    editor = {
                      enable = true;
                      defaultEditor = "neovim";
                      vim.enable = false;
                      neovim.enable = true;
                      emacs = {
                        enable = true;
                        programs.package = pkgs.emacs31-pgtk;
                        services.package = pkgs.emacs-pgtk-twist;
                      };
                    };
                    greeter.enable = true;
                    niri = {
                      enable = true;
                      noctalia.enable = true;
                      waybar.enable = false;
                    };
                    x11-session.enable = true;
                  };
                };
              };
            })
          ];
        };
        
        nixos-server = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.modules.features.share
            self.modules.features.editor
            self.modules.features.secret
            self.modules.hosts.aliyun
            self.modules.users.lingyu-minimal
            {
              config = {
                modules = {
                  base = {
                    createXdgUserDirectories = false;
                  };
                  features = {
                    shell.enable = true;
                    secret.enable = false;
                  };
                };
              };
            }
          ];
        };
        
        nixos-wsl = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.modules.features.share
            self.modules.features.editor
            self.modules.features.secret
            self.modules.hosts.wsl
            self.modules.users.lingyu
            {
              config = {
                modules = {
                  base = {
                    allowUnfreePredicateList = [
                      "github-copilot-cli"
                    ];
                    createXdgUserDirectories = false;
                  };
                  features = {
                    shell.enable = true;
                    font.enable = true;
                    texlive.enable = true;
                    office.enable = false;
                    media.enable = false;
                    remote.enable = true;
                    agent.enable = true;
                    secret.enable = true;
                    editor = {
                      enable = true;
                      defaultEditor = "neovim";
                      vim.enable = false;
                      neovim.enable = true;
                      emacs.enable = true;
                    };
                  };
                };
              };
            }
          ];
        };
        
      };
      
    };
    
    perSystem = { inputs', pkgs, ... } : {
      apps = {
        nixos-anywhere = {
          type = "app";
          program = (pkgs.lib.getExe' inputs'.nixos-anywhere.packages.default "nixos-anywhere");
          meta.description = "Run nixos-anywhere from this flake";
        };
      };
    };
    
  };
  
}
