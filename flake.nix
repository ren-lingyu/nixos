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
    flake-parts = {
      url = "git+https://github.com/hercules-ci/flake-parts.git?ref=refs/heads/main&shallow=1";
    };
    treefmt-nix = {
      url = "git+https://github.com/numtide/treefmt-nix.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
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
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    sops-nix = {
      url = "git+https://github.com/Mic92/sops-nix.git?ref=refs/heads/master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emarccs = {
      url = "git+https://github.com/ren-lingyu/emarccs.git?ref=refs/heads/main&shallow=1";
    };
    nixvim = {
      # the main branch of nixvim must be use in nixos-unstable
      url = "git+https://github.com/nix-community/nixvim.git?ref=refs/heads/main&shallow=1";
    };
    lem = {
      url = "git+https://github.com/lem-project/lem.git?ref=refs/heads/main&shallow=1";
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
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    disko = {
      # url = "git+https://github.com/nix-community/disko.git?ref=refs/heads/master&shallow=1";
      follows = "nixos-anywhere/disko";
    };
    lean4-nix = {
      url = "git+https://github.com/lenianiva/lean4-nix.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zotero-fix-nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?rev=363fdbe57ed052c76e816e6270206b0cb348e53a&shallow=1";
    };
    git-agent-workflow = {
      url = "git+https://github.com/ren-lingyu/git-agent-workflow.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake
      {

        inherit inputs;

        specialArgs = rec {
          rootPath = ./.;
          llib = import ./lib { lib = inputs.nixpkgs.lib; };
          lpkgs = import ./pkgs { inherit llib; };
        };

      }
      (
        {
          rootPath,
          llib,
          lpkgs,
          config,
          ...
        }:
        {

          imports = [
            inputs.treefmt-nix.flakeModule
            inputs.agenix-rekey.flakeModule
          ];

          options =
            let
              lib = inputs.nixpkgs.lib;
            in
            {

              nixosBuilder = {
                nixosSystem = lib.mkOption {
                  type = lib.types.raw;
                  description = "Function used to construct NixOS configurations.";
                };
                homeManager = lib.mkOption {
                  type = lib.types.deferredModule;
                  description = "Home Manager integration module for NixOS.";
                };
                specialArgs = lib.mkOption {
                  type = lib.types.attrsOf lib.types.raw;
                  default = { };
                  description = "Additional module arguments shared by NixOS and Home Manager.";
                };
              };

              moduleIntegrations = llib.moduleFunctions.default.mkOptionTree {
                root = ./.;
                modulesDir = ./modules;
                pathMapper = lib.drop 1;
                optionMaker =
                  moduleDescriptor_:
                  lib.mkOption {
                    type = lib.types.submodule {
                      options = {
                        nixosModules = lib.mkOption {
                          type = lib.types.listOf lib.types.deferredModule;
                          default = [ ];
                          description = "Additional NixOS modules required by this module.";
                        };
                        nixpkgsOverlays = lib.mkOption {
                          type = lib.types.listOf (
                            lib.mkOptionType {
                              name = "nixpkgs.overlay";
                              description = "Nixpkgs overlay";
                              check = lib.isFunction;
                              merge = lib.mergeOneOption;
                            }
                          );
                          default = [ ];
                          description = "Additional Nixpkgs overlays required by this module.";
                        };
                        homeModules = lib.mkOption {
                          type = lib.types.listOf lib.types.deferredModule;
                          default = [ ];
                          description = "Additional Home Manager modules for users selected by this module.";
                        };
                      };
                    };
                    default = { };
                    description = "External integrations for ${lib.concatStringsSep "." moduleDescriptor_.path}.";
                  };
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

            moduleIntegrations = {

              share = {
                nixosModules = [
                  inputs.agenix.nixosModules.default
                  inputs.agenix-rekey.nixosModules.default
                  config.flake.nixosModules.default
                ];
                nixpkgsOverlays = [
                  inputs.emarccs.overlays.default
                  (final: prev: {
                    lean4 = inputs.lean4-nix.packages.${final.stdenv.hostPlatform.system}.lean-bin;
                    zotero = inputs.zotero-fix-nixpkgs.legacyPackages.${final.stdenv.hostPlatform.system}.zotero;
                  })
                  inputs.git-agent-workflow.overlays.default
                  config.flake.overlays.default
                ];
                homeModules = [ config.flake.homeModules.default ];
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
                  nixpkgsOverlays = [
                    inputs.lem.overlays.default
                    (final_: prev_: {
                      lem-webview = final_.symlinkJoin {
                        name = "${prev_.lem-webview.name}-with-desktop";
                        paths = [
                          prev_.lem-webview
                          (final_.makeDesktopItem {
                            name = "lem";
                            desktopName = "Lem";
                            genericName = "Text Editor";
                            comment = "Common Lisp editor/IDE with high expansibility";
                            exec = "${prev_.lib.getExe prev_.lem-webview} %F";
                            icon = "lem";
                            terminal = false;
                            categories = [
                              "Development"
                              "TextEditor"
                            ];
                            mimeTypes = [
                              "text/english"
                              "text/plain"
                              "text/x-makefile"
                              "text/x-c++hdr"
                              "text/x-c++src"
                              "application/x-shellscript"
                              "text/x-c"
                              "text/x-c++"
                            ];
                          })
                          (final_.writeTextFile {
                            name = "lem-icon";
                            destination = "/share/icons/hicolor/scalable/apps/lem.svg";
                            text = builtins.readFile "${inputs.lem}/scripts/install/lem.svg";
                          })
                        ];
                        meta = prev_.lem-webview.meta;
                      };
                    })
                  ];
                  homeModules = [ inputs.nixvim.homeModules.nixvim ];
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

            flake = {

              nixosModules = {
                default = lpkgs.nixosModule;
              };

              homeModules = {
                default = lpkgs.homeModule;
              };

              overlays = {
                default = lpkgs.overlay;
              };

              modules =
                let
                  moduleIntegrations_ = config.moduleIntegrations;
                  nixosBuilder_ = config.nixosBuilder;
                in
                {

                  base =
                    {
                      config,
                      pkgs,
                      lib,
                      ...
                    }:
                    {
                      _file = ./flake.nix;
                      key = "${builtins.toString ./flake.nix}#self.modules.base";
                      imports = builtins.concatLists [
                        [ nixosBuilder_.homeManager ]
                        moduleIntegrations_.share.nixosModules
                        [
                          ./modules/share/os
                          ./modules/features
                          ./modules/hosts
                          ./modules/users
                          ./modules/workloads
                        ]
                      ];
                      config = {
                        _module.args = nixosBuilder_.specialArgs;
                        nixpkgs = {
                          overlays = moduleIntegrations_.share.nixpkgsOverlays;
                        };
                        home-manager = {
                          sharedModules = builtins.concatLists [
                            moduleIntegrations_.share.homeModules
                            [ ./modules/share/hm ]
                          ];
                          extraSpecialArgs = nixosBuilder_.specialArgs;
                        };
                      };
                    };

                  features = {
                    niri =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = [
                          self.modules.base
                          ./modules/features/niri
                        ];
                        config = {
                          nixpkgs = {
                            overlays = moduleIntegrations_.features.niri.nixpkgsOverlays;
                          };
                          home-manager.sharedModules = moduleIntegrations_.features.niri.homeModules;
                        };
                      };
                    sops =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = builtins.concatLists [
                          [
                            self.modules.base
                            ./modules/features/sops
                          ]
                          moduleIntegrations_.features.sops.nixosModules
                        ];
                        config = {
                          home-manager.sharedModules = moduleIntegrations_.features.sops.homeModules;
                        };
                      };
                    editor =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = [
                          self.modules.base
                          ./modules/features/editor
                        ];
                        config = {
                          nixpkgs = {
                            overlays = moduleIntegrations_.features.editor.nixpkgsOverlays;
                          };
                          home-manager.sharedModules = moduleIntegrations_.features.editor.homeModules;
                        };
                      };
                    share =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = [
                          self.modules.base
                          ./modules/features/agent
                          ./modules/features/diagnostics
                          ./modules/features/file-manager
                          ./modules/features/font
                          ./modules/features/greeter
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
                    lingyu =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = [ self.modules.base ];
                        config.modules = {
                          users.lingyu = {
                            enable = true;
                            username = "lingyu";
                            homeDirectory = "/home/lingyu";
                          };
                        };
                      };
                    lingyu-minimal =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = [ self.modules.base ];
                        config.modules.users.lingyu-minimal = {
                          enable = true;
                          username = "lingyu";
                          homeDirectory = "/home/lingyu";
                        };
                      };
                  };

                  workloads = {
                    caddy =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = [
                          self.modules.base
                          ./modules/workloads/caddy
                        ];
                      };
                    wbo =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = [
                          self.modules.base
                          ./modules/workloads/wbo
                        ];
                      };
                  };

                  hosts = {
                    wsl =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = builtins.concatLists [
                          moduleIntegrations_.hosts.wsl.nixosModules
                          [
                            self.modules.base
                            ./modules/hosts/wsl
                          ]
                        ];
                      };
                    thinkbook =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = builtins.concatLists [
                          moduleIntegrations_.hosts.thinkbook.nixosModules
                          [
                            self.modules.base
                            self.modules.workloads.wbo
                            ./modules/hosts/thinkbook
                          ]
                        ];
                        config.modules = {
                          hosts.thinkbook = {
                            flatpak.enable = true;
                          };
                          workloads.wbo = {
                            enable = true;
                            ip = config.networking.wireguard.topology."3".nodes."2";
                            port = 18000;
                            networkInterface = config.networking.wireguard.topology."3".name;
                            allowedSourceIp = config.networking.wireguard.topology."3".nodes."3";
                          };
                        };
                      };
                    aliyun =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = builtins.concatLists [
                          moduleIntegrations_.hosts.aliyun.nixosModules
                          [
                            self.modules.base
                            self.modules.workloads.caddy
                            ./modules/hosts/aliyun
                          ]
                        ];
                        config.modules = {
                          workloads.caddy = {
                            enable = true;
                            ip = config.networking.wireguard.topology."3".nodes."2";
                            port = 18000;
                            networkInterface = config.networking.wireguard.topology."3".name;
                          };
                        };
                      };
                    matebook =
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        imports = [
                          self.modules.base
                          ./modules/hosts/matebook
                        ];
                      };
                  };

                };

              nixosConfigurations = {

                nixos = config.nixosBuilder.nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                    self.modules.features.share
                    self.modules.features.editor
                    self.modules.features.niri
                    self.modules.features.sops
                    self.modules.hosts.thinkbook
                    self.modules.users.lingyu
                    (
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        config = {
                          modules = {
                            base = {
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
                      }
                    )
                  ];
                };

                nixos-matebook = config.nixosBuilder.nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                    self.modules.features.share
                    self.modules.features.editor
                    self.modules.features.niri
                    self.modules.features.sops
                    self.modules.hosts.matebook
                    self.modules.users.lingyu
                    (
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        config = {
                          modules = {
                            base = {
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
                            users = {
                              lingyu.uid = config.modules.hosts.matebook.users."1000";
                            };
                          };
                        };
                      }
                    )
                  ];
                };

                nixos-server = config.nixosBuilder.nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                    self.modules.features.share
                    self.modules.features.editor
                    self.modules.features.sops
                    self.modules.hosts.aliyun
                    self.modules.users.lingyu-minimal
                    (
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        config = {
                          modules = {
                            base = {
                              createXdgUserDirectories = false;
                            };
                            features = {
                              shell.enable = true;
                              sops.enable = true;
                            };
                            users = {
                              lingyu-minimal.uid = config.modules.hosts.aliyun.users."1000";
                            };
                          };
                        };
                      }
                    )
                  ];
                };

                nixos-wsl = config.nixosBuilder.nixosSystem {
                  system = "x86_64-linux";
                  modules = [
                    self.modules.features.share
                    self.modules.features.editor
                    self.modules.features.sops
                    self.modules.hosts.wsl
                    self.modules.users.lingyu
                    (
                      {
                        config,
                        pkgs,
                        lib,
                        ...
                      }:
                      {
                        config = {
                          modules = {
                            base = {
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
                            users.lingyu.uid = config.modules.hosts.wsl.users."1000";
                          };
                        };
                      }
                    )
                  ];
                };

              };

            };

            perSystem =
              {
                inputs',
                config,
                pkgs,
                lib,
                final,
                ...
              }:
              {

                legacyPackages = lpkgs.mkLegacyPackages pkgs;

                checks = import ./tests { inherit pkgs llib; };

                devShells = {
                  deploy = pkgs.mkShell { nativeBuildInputs = [ inputs'.nixos-anywhere.packages.default ]; };
                  secret = pkgs.mkShell {
                    nativeBuildInputs = [
                      config.agenix-rekey.package
                      pkgs.age-plugin-yubikey
                    ];
                  };
                };

                agenix-rekey.agePackage = config.legacyPackages.rage-armored;

                treefmt = {
                  flakeFormatter = true;
                  flakeCheck = true;
                  enableDefaultExcludes = false;
                  projectRootFile = builtins.baseNameOf __curPos.file;
                  settings.excludes = [
                    "flake.lock"
                    "*.patch"
                    ".gitignore"
                    "LICENSE"
                  ];
                  programs = {
                    nixfmt = {
                      enable = true;
                      package = pkgs.nixfmt;
                      width = 100;
                      indent = 2;
                      strict = true;
                    };
                    shfmt = {
                      enable = true;
                      package = pkgs.shfmt;
                      indent_size = 2;
                      simplify = false;
                    };
                    prettier = {
                      enable = true;
                      package = pkgs.prettier;
                      settings = {
                        printWidth = 100;
                        tabWidth = 2;
                        proseWrap = "preserve";
                        endOfLine = "lf";
                      };
                    };
                  };
                };

              };

          };

        }
      );

}
