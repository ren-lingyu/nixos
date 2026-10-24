{
  description = "NixOS configuration";

  nixConfig = {
    auto-optimise-store = true;
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    extra-substituters = [ "https://noctalia.cachix.org" ];
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
    personal-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    local-nixpkgs = {
      url = "path:./pkgs";
    };
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager.git?ref=refs/heads/master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "git+https://github.com/ryantm/agenix.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "git+https://github.com/oddlama/agenix-rekey.git?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "personal-nixpkgs/treefmt-nix";
      };
    };
    sops-nix = {
      url = "git+https://github.com/Mic92/sops-nix.git?ref=refs/heads/master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "git+https://github.com/sodiboo/niri-flake.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "git+https://github.com/gmodena/nix-flatpak.git?ref=refs/tags/latest&shallow=1";
    };
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "git+https://github.com/nix-community/NixOS-WSL.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "git+https://github.com/nix-community/nixos-anywhere.git?ref=refs/heads/main&shallow=1";
      inputs.treefmt-nix.follows = "personal-nixpkgs/treefmt-nix";
    };
    disko = {
      # url = "git+https://github.com/nix-community/disko.git?ref=refs/heads/master&shallow=1";
      follows = "nixos-anywhere/disko";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.personal-nixpkgs.lib.mkFlake inputs.nixpkgs
      {
        inherit inputs;
        moduleLocation = __curPos.file;
        llib = inputs.personal-nixpkgs.lib.mergeAttrsRecursive { allowOverrides = false; } [
          { inherit (inputs.personal-nixpkgs.lib) tests; }
          (import ./lib { lib = inputs.nixpkgs.lib; })
        ];
        specialArgs = rec {
          rootPath = ./.;
        };
      }
      (
        {
          rootPath,
          llib,
          config,
          lib,
          ...
        }:
        {
          imports = [ inputs.agenix-rekey.flakeModule ];

          options =
            let
              args_ = {
                inherit llib;
                modules = ./modules;
              };
            in
            {
              nixosBuilder = lib.mkOption {
                type = llib.flakeParts.types.nixosBuilder;
                readOnly = true;
              };
              moduleRegistry = lib.mkOption {
                apply = (llib.flakeParts.mkValidatorApplications args_).moduleRegistry;
                type = llib.flakeParts.types.moduleRegistry args_;
                readOnly = true;
              };
              nixosConfigurations = lib.mkOption {
                apply = (llib.flakeParts.mkValidatorApplications args_).nixosConfigurations config.moduleRegistry;
                type = llib.flakeParts.types.nixosConfigurations {
                  inherit (args_) modules llib;
                  registry = config.moduleRegistry;
                };
                readOnly = true;
              };
            };

          config = {
            debug = true;

            systems = [ "x86_64-linux" ];

            nixosBuilder = {
              nixosSystem = inputs.nixpkgs.lib.nixosSystem;
              homeManager = inputs.home-manager.nixosModules.home-manager;
              specialArgs = { inherit llib rootPath; };
            };

            moduleRegistry = {
              share = {
                nixosModules = [
                  inputs.agenix.nixosModules.default
                  inputs.agenix-rekey.nixosModules.default
                  inputs.local-nixpkgs.nixosModules.share
                ];
                nixpkgsOverlays = [ inputs.local-nixpkgs.overlays.share ];
                homeModules = [ inputs.local-nixpkgs.homeModules.share ];
              };

              hosts = {
                wsl = {
                  nixosModules = [ inputs.nixos-wsl.nixosModules.default ];
                };
                thinkbook = {
                  nixosModules = [
                    inputs.nix-flatpak.nixosModules.nix-flatpak
                    inputs.nixvirt.nixosModules.default
                  ];
                };
                aliyun = {
                  nixosModules = [ inputs.disko.nixosModules.disko ];
                };
              };

              features = {
                editor = {
                  nixpkgsOverlays = [ inputs.local-nixpkgs.overlays.editor ];
                  homeModules = [ inputs.local-nixpkgs.homeModules.editor ];
                };
                niri = {
                  nixpkgsOverlays = [ inputs.niri-flake.overlays.niri ];
                  homeModules = [ inputs.niri-flake.homeModules.niri ];
                };
                sops = {
                  nixosModules = [ inputs.sops-nix.nixosModules.sops ];
                  homeModules = [ inputs.sops-nix.homeManagerModules.sops ];
                };
              };
            };

            nixosConfigurations = {
              nixos = {
                system = "x86_64-linux";
                modules = {
                  share = {
                    enable = true;
                    allowUnfreePredicateList = [
                      "github-copilot-cli"
                      "microsoft-edge"
                      "feishu"
                      "zoom"
                      "rar"
                      "unrar"
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
                        programs.package = { pkgs, ... }: pkgs.emacs-pgtk;
                        services.package = { pkgs, ... }: pkgs.emarccs-pgtk;
                      };
                      lem = {
                        enable = true;
                        package = { pkgs, ... }: pkgs.lem-webview;
                      };
                    };
                    file-manager.enable = true;
                    font.enable = true;
                    greeter.enable = true;
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
                  hosts = {
                    thinkbook = {
                      enable = true;
                      flatpak.enable = true;
                    };
                  };
                  workloads.wbo = {
                    enable = true;
                    ip = { config, ... }: config.networking.wireguard.topology."3".nodes."2";
                    port = _: 18000;
                    networkInterface = { config, ... }: config.networking.wireguard.topology."3".name;
                    allowedSourceIp = { config, ... }: config.networking.wireguard.topology."3".nodes."3";
                  };
                  users = {
                    lingyu = {
                      enable = true;
                      username = "lingyu";
                      homeDirectory = "/home/lingyu";
                      uid = config.moduleRegistry.hosts.thinkbook.metadata.users."1000";
                    };
                  };
                };
              };

              nixos-matebook = {
                system = "x86_64-linux";
                modules = {
                  share = {
                    enable = true;
                    allowUnfreePredicateList = [ "github-copilot-cli" ];
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
                        programs.package = { pkgs, ... }: pkgs.emacs-pgtk;
                        services.package = { pkgs, ... }: pkgs.emarccs-pgtk;
                      };
                      lem = {
                        enable = true;
                        package = { pkgs, ... }: pkgs.lem-webview;
                      };
                    };
                    file-manager.enable = true;
                    font.enable = true;
                    greeter.enable = true;
                    media.enable = true;
                    niri = {
                      enable = true;
                      noctalia.enable = true;
                      waybar.enable = false;
                    };
                    proxy = {
                      enable = true;
                      clash-verge.enable = true;
                      throne.enable = false;
                    };
                    sops.enable = true;
                    shell.enable = true;
                    terminal.enable = true;
                    texlive.enable = true;
                  };
                  hosts = {
                    matebook = {
                      enable = true;
                    };
                  };
                  users = {
                    lingyu = {
                      enable = true;
                      username = "lingyu";
                      homeDirectory = "/home/lingyu";
                      uid = config.moduleRegistry.hosts.matebook.metadata.users."1000";
                    };
                  };
                };
              };

              nixos-server = {
                system = "x86_64-linux";
                modules = {
                  share = {
                    enable = true;
                    createXdgUserDirectories = false;
                  };
                  features = {
                    shell.enable = true;
                    sops.enable = true;
                  };
                  hosts = {
                    aliyun = {
                      enable = true;
                    };
                  };
                  workloads.caddy = {
                    enable = true;
                    ip = { config, ... }: config.networking.wireguard.topology."3".nodes."2";
                    port = _: 18000;
                    networkInterface = { config, ... }: config.networking.wireguard.topology."3".name;
                  };
                  users = {
                    lingyu-minimal = {
                      enable = true;
                      username = "lingyu";
                      homeDirectory = "/home/lingyu";
                      uid = config.moduleRegistry.hosts.aliyun.metadata.users."1000";
                    };
                  };
                };
              };

              nixos-wsl = {
                system = "x86_64-linux";
                modules = {
                  share = {
                    enable = true;
                    allowUnfreePredicateList = [ "github-copilot-cli" ];
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
                  hosts = {
                    wsl = {
                      enable = true;
                    };
                  };
                  users = {
                    lingyu = {
                      enable = true;
                      username = "lingyu";
                      homeDirectory = "/home/lingyu";
                      uid = config.moduleRegistry.hosts.wsl.metadata.users."1000";
                    };
                  };
                };
              };
            };

            flake = {
              nixosConfigurations = llib.flakeParts.mkNixosConfigurations {
                modules = ./modules;
                builder = config.nixosBuilder;
                registry = config.moduleRegistry;
                configurations = config.nixosConfigurations;
              };
            };

            perSystem =
              {
                inputs',
                system,
                config,
                pkgs,
                lib,
                final,
                ...
              }:
              {
                nixpkgs.overlays = [ inputs.local-nixpkgs.overlays.legacy ];

                legacyPackages = pkgs.legacyPackages;

                checks = import ./tests {
                  inherit lib pkgs llib;
                  modules = ./modules;
                };

                devShells = {
                  deploy = pkgs.mkShell { nativeBuildInputs = [ inputs'.nixos-anywhere.packages.default ]; };
                  secret = pkgs.mkShell {
                    nativeBuildInputs = [
                      config.agenix-rekey.package
                      pkgs.age-plugin-yubikey
                    ];
                  };
                };

                agenix-rekey.agePackage = pkgs.rage-armored;

                treefmt = {
                  flakeCheck = true;
                  settings.excludes = [
                    "*.patch"
                    ".gitignore"
                    "LICENSE"
                    "README.org"
                    "flake.lock"
                    "*.age"
                  ];
                };
              };
          };
        }
      );
}
