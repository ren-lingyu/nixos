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
    lem = {
      url = "git+https://github.com/lem-project/lem.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
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

      lib = import ./lib;

      modules = {

        base = { config, pkgs, lib, ... } : let
          llib = self.lib { inherit lib; };
        in {
          _file = ./flake.nix;
          key = "${builtins.toString ./flake.nix}#self.modules.base";
          imports = [
            inputs.home-manager.nixosModules.home-manager
            ./modules
          ];
          config = {
            # `llib` must be available before profile submodules are evaluated.
            # Home Manager has a separate argument scope, so it is passed again below.
            _module.args = {
              llib = llib;
            };
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
                inherit llib;
              };
            };
          };
        };

        features = {
          niri = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
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
          sops = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              inputs.sops-nix.nixosModules.sops
              ./modules/features/sops
            ];
            config = {
              home-manager.sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
            };
          };
          editor = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              ./modules/features/editor
            ];
            config = {
              nixpkgs = {
                overlays = [
                  inputs.lem.overlays.default
                ];
              };
              home-manager.sharedModules = [
                inputs.nixvim.homeModules.nixvim
              ];
            };
          };
          share = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
              ./modules/features/agent
              ./modules/features/diagnostics
              ./modules/features/file-manager
              ./modules/features/font
              ./modules/features/greeter
              ./modules/features/interconnect
              ./modules/features/media
              ./modules/features/office
              ./modules/features/proxy
              ./modules/features/shell
              ./modules/features/terminal
              ./modules/features/texlive
              ./modules/features/x11-session
            ];
          };
        };

        users = {
          lingyu = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
            ];
            config.modules = {
              users.lingyu = {
                enable = true;
                username = "lingyu";
                homeDirectory = "/home/lingyu";
              };
            };
          };
          lingyu-minimal = { config, pkgs, lib, ... } : {
            imports = [
              self.modules.base
            ];
            config.modules.users.lingyu-minimal = {
              enable = true;
              username = "lingyu";
              homeDirectory = "/home/lingyu";
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
            self.modules.features.sops
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
                    agent.enable = true;
                    diagnostics.enable = true;
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
                      lem = {
                        enable = true;
                        package = pkgs.lem-webview;
                      };
                    };
                    file-manager.enable = true;
                    font.enable = true;
                    greeter.enable = true;
                    interconnect.enable = true;
                    media.enable = true;
                    niri = {
                      enable = true;
                      noctalia.enable = true;
                      waybar.enable = false;
                    };
                    office.enable = true;
                    proxy = {
                      enable = true;
                      clash-verge.enable = true;
                      throne.enable = true;
                    };
                    sops.enable = true;
                    shell.enable = true;
                    terminal.enable = true;
                    texlive.enable = true;
                    x11-session.enable = true;
                  };
                  users = {
                    lingyu.uid = config.modules.hosts.thinkbook.users."1000";
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
            self.modules.features.sops
            self.modules.hosts.aliyun
            self.modules.users.lingyu-minimal
            ({ config, pkgs, lib, ... } : {
              config = {
                modules = {
                  base = {
                    createXdgUserDirectories = false;
                  };
                  features = {
                    interconnect.enable = true;
                    sops.enable = true;
                    shell.enable = true;
                  };
                  users = {
                    lingyu-minimal.uid = config.modules.hosts.aliyun.users."1000";
                  };
                };
              };
            })
          ];
        };

        nixos-wsl = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            self.modules.features.share
            self.modules.features.editor
            self.modules.features.sops
            self.modules.hosts.wsl
            self.modules.users.lingyu
            ({ config, pkgs, lib, ... } : {
              config = {
                modules = {
                  base = {
                    allowUnfreePredicateList = [
                      "github-copilot-cli"
                    ];
                    createXdgUserDirectories = false;
                  };
                  features = {
                    agent.enable = true;
                    diagnostics.enable = true;
                    editor = {
                      enable = true;
                      defaultEditor = "neovim";
                      vim.enable = false;
                      neovim.enable = true;
                      emacs.enable = true;
                    };
                    file-manager.enable = true;
                    font.enable = true;
                    media.enable = false;
                    office.enable = false;
                    sops.enable = true;
                    shell.enable = true;
                    terminal.enable = true;
                    texlive.enable = true;
                  };
                  users.lingyu.uid = config.modules.hosts.wsl.users."1000";
                };
              };
            })
          ];
        };

      };

    };

    perSystem = { inputs', pkgs, ... } : let

      llib = self.lib { lib = pkgs.lib; };

      checks = import ./tests {
        inherit llib;
        inherit pkgs;
      };

    in {

      inherit checks;

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
