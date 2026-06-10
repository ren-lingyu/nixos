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
    noctalia = {
      url = "git+https://github.com/noctalia-dev/noctalia.git?ref=refs/tags/v4.7.7&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "git+https://github.com/gmodena/nix-flatpak.git?ref=refs/tags/latest&shallow=1";
    };
    emarccs = {
      url = "git+https://github.com/ren-lingyu/emarccs.git?ref=refs/heads/main&shallow=1";
    };
    nixos-anywhere = {
      url = "git+https://github.com/nix-community/nixos-anywhere.git?ref=refs/heads/main&shallow=1";
    };
    disko = {
      # url = "git+https://github.com/nix-community/disko.git?ref=refs/heads/master&shallow=1";
      follows = "nixos-anywhere/disko";
    };
  };
  
  outputs = { self, ... }@inputs : {

    packages = {
      x86_64-linux = {
        nixos-anywhere = inputs.nixos-anywhere.packages.x86_64-linux.default;
      };
    };
    
    nixosModules = {
      
      base = { config, pkgs, lib, ... } : {
        imports = [
          inputs.home-manager.nixosModules.home-manager
          ./modules
        ];
        config = {
          nixpkgs.overlays = [
            (final: prev: {
              arcc = inputs.arcc-nixpkgs.packages."${prev.system}";
            })
          ];
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        };
      };
      
      features = {
        niri = { config, pkgs, lib, ... } : {
          imports = [
            self.nixosModules.base
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
            self.nixosModules.base
            inputs.sops-nix.nixosModules.sops
            ./modules/features/secret
          ];
          config = {
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
          };
        };
        share = { config, pkgs, lib, ... } : {
          imports = [
            self.nixosModules.base
            ./modules/features/remote
            ./modules/features/texlive
            ./modules/features/font
            ./modules/features/shell
            ./modules/features/media
            ./modules/features/office
            ./modules/features/agent
          ];
        };
      };
      
      users = {
        lingyu = { config, pkgs, lib, ... } : {
          imports = [
            self.nixosModules.base
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
        lingyu-minimal = { config, pkgs, lib, ... } : {
          imports = [
            self.nixosModules.base
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
            self.nixosModules.base
            inputs.nixos-wsl.nixosModules.default
            inputs.vscode-server.nixosModules.default
            ./modules/hosts/wsl
          ];
        };
        thinkbook = { config, pkgs, lib, ... } : {
          imports = [
            self.nixosModules.base
            inputs.nix-flatpak.nixosModules.nix-flatpak
            ./modules/hosts/thinkbook
          ];
          config.modules.hosts = {
            packageGroups.tencent.enable = true;
          };
        };
        aliyun = { config, pkgs, lib, ... } : {
          imports = [
            self.nixosModules.base
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
          self.nixosModules.features.share
          self.nixosModules.features.niri
          self.nixosModules.features.secret
          self.nixosModules.hosts.thinkbook
          self.nixosModules.users.lingyu
          {
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
                  ];
                  createXdgUserDirectories = true;
                };
                features = {
                  remote.enable = true;
                  font.enable = true;
                  media.enable = true;
                  office.enable = true;
                  shell.enable = true;
                  texlive.enable = true;
                  agent.enable = true;
                  secret.enable = true;
                  niri = {
                    enable = true;
                    greeter.enable = true;
                    monitor = {
                      name = "eDP-1";
                      width = 3072;
                      height = 1920;
                    };
                    noctalia.enable = true;
                    waybar.enable = false;
                  };
                };
              };
            };
          }
        ];
      };
      nixos-server = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          self.nixosModules.features.share
          self.nixosModules.features.secret
          self.nixosModules.hosts.aliyun
          self.nixosModules.users.lingyu-minimal
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
          self.nixosModules.features.share
          self.nixosModules.features.secret
          self.nixosModules.hosts.wsl
          self.nixosModules.users.lingyu
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
                  remote.enable = true;
                  font.enable = true;
                  media.enable = false;
                  office.enable = false;
                  shell.enable = true;
                  texlive.enable = true;
                  secret.enable = true;
                };
              };
            };
          }
        ];
      };
    };
    
  };
  
}
