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
    };
    personal-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs?ref=refs/heads/main&shallow=1";
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
    };
    disko = {
      # url = "git+https://github.com/nix-community/disko.git?ref=refs/heads/master&shallow=1";
      follows = "nixos-anywhere/disko";
    };
    niri-flake = {
      url = "git+https://github.com/sodiboo/niri-flake.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emarccs = {
      url = "git+https://github.com/ren-lingyu/emarccs.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      # the main branch of nixvim must be use in nixpkgs-unstable
      url = "git+https://github.com/nix-community/nixvim.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lem = {
      url = "git+https://github.com/lem-project/lem.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lean4-nix = {
      url = "git+https://github.com/lenianiva/lean4-nix.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-agent-workflow = {
      url = "git+https://github.com/ren-lingyu/git-agent-workflow.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.personal-nixpkgs.lib.mkFlake inputs.nixpkgs
      ({ lib }: {
        inherit inputs;
        moduleLocation = __curPos.file;
        llib = inputs.personal-nixpkgs.lib.mergeAttrsRecursive { allowOverrides = false; } [
          { inherit (inputs.personal-nixpkgs.lib) tests; }
          (import ./lib { inherit lib; })
        ];
        lpkgs = import ./pkgs {
          inherit lib;
          llib = { inherit (inputs.personal-nixpkgs.lib) packages; };
          overlays = {
            emarccs = inputs.emarccs.overlays.default;
            git-agent-workflow = inputs.git-agent-workflow.overlays.default;
            lean4 = final_: prev_: {
              lean4 = inputs.lean4-nix.packages.${final_.stdenv.hostPlatform.system}.lean-bin;
            };
            lem = inputs.lem.overlays.default;
          };
        };
        specialArgs = {
          rootPath = ./.;
        };
      })
      (
        {
          rootPath,
          llib,
          lpkgs,
          config,
          lib,
          ...
        }@fpArgs:
        {
          imports = [
            inputs.agenix-rekey.flakeModule
            ./modules
          ];

          options = llib.flakeParts.mkOptions config;

          config = {
            debug = true;

            systems = [ "x86_64-linux" ];

            nixosBuilderArgs = {
              nixosSystem = inputs.nixpkgs.lib.nixosSystem;
              homeManager = inputs.home-manager.nixosModules.home-manager;
              specialArgs = { inherit llib rootPath; };
              baseModule = {
                imports = [
                  inputs.agenix.nixosModules.default
                  inputs.agenix-rekey.nixosModules.default
                  lpkgs.nixosModule
                ];
                nixpkgs.overlays = [ lpkgs.overlays.share ];
                home-manager.sharedModules = [ lpkgs.homeModule ];
              };

              hostRegistry = {
                thinkbook.module.imports = [
                  inputs.nix-flatpak.nixosModules.nix-flatpak
                  inputs.nixvirt.nixosModules.default
                ];
                aliyun.module.imports = [ inputs.disko.nixosModules.disko ];
                wsl.module.imports = [ inputs.nixos-wsl.nixosModules.default ];
              };

              featureRegistry = {
                os = {
                  editor = { config, lib, ... }: {
                    config = lib.mkIf config.features.editor.enable { nixpkgs.overlays = [ lpkgs.overlays.editor ]; };
                  };
                  niri = { config, lib, ... }: {
                    config = lib.mkIf config.features.niri.enable {
                      nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];
                    };
                  };
                };
                hm = {
                  editor = lib.mkBefore inputs.nixvim.homeModules.nixvim;
                  niri = lib.mkBefore inputs.niri-flake.homeModules.niri;
                };
              };
            };

            nixosConfigurations = {
              nixos = {
                host = config.nixosBuilderArgs.hostRegistry.thinkbook;

                features = {
                  agent.enable = true;
                  editor.enable = true;
                  file-manager = {
                    enable = true;
                    module = {
                      features.file-manager.fileChooser.enable = true;
                    };
                  };
                  font.enable = true;
                  greeter.enable = true;
                  media.enable = true;
                  niri = {
                    enable = true;
                    module = {
                      features.niri.noctalia.enable = true;
                    };
                  };
                  proxy = {
                    enable = true;
                    module = {
                      features.proxy = {
                        clash-verge.enable = true;
                        throne.enable = true;
                      };
                    };
                  };
                  shell.enable = true;
                  texlive.enable = true;
                  x11-session.enable = true;
                };

                workloads.wbo = {
                  enable = true;
                  module.workloads.wbo = {
                    ip = config.nixosBuilderArgs.hostTopology.aliyun.nodes.thinkbook;
                    port = 18000;
                    networkInterface = config.nixosBuilderArgs.hostTopology.aliyun.name;
                    allowedSourceIp = config.nixosBuilderArgs.hostTopology.aliyun.nodes.aliyun;
                  };
                };

                users."1000" = {
                  username = "lingyu";
                  profile = config.nixosBuilderArgs.userRegistry.lingyu;

                  secrets = {
                    nutstore = {
                      user.enable = true;
                      pass.enable = true;
                    };
                    "123cloud" = {
                      user.enable = true;
                      pass.enable = true;
                    };
                    cloudflare = {
                      access_key_id.enable = true;
                      secret_access_key.enable = true;
                      endpoint.enable = true;
                    };
                    alibabacloud.oss = {
                      access_key_id.enable = true;
                      secret_access_key.enable = true;
                    };
                    deepseek.apiKey.pi.enable = true;
                    moonshot.cn.apiKey.pi.enable = true;
                    zai.cn.apiKey.pi.enable = true;
                  };

                  features = {
                    agent.enable = true;
                    diagnostics.enable = true;
                    editor = {
                      enable = true;
                      module = { pkgs, ... }: {
                        features.editor = {
                          defaultEditor = "neovim";
                          neovim.enable = true;
                          emacs.enable = true;
                          emacs.programs.package = pkgs.emacs-pgtk;
                          emacs.services.package = pkgs.emarccs-pgtk;
                          lem = {
                            enable = true;
                            package = pkgs.lem-webview;
                          };
                        };
                      };
                    };
                    file-manager.enable = true;
                    font.enable = true;
                    media.enable = true;
                    niri = {
                      enable = true;
                      module = {
                        features.niri.waybar.enable = false;
                      };
                    };
                    office.enable = true;
                    shell.enable = true;
                    terminal.enable = true;
                    x11-session.enable = true;
                  };
                };
              };

              nixos-matebook = {
                host = config.nixosBuilderArgs.hostRegistry.matebook;

                features = {
                  agent.enable = true;
                  editor.enable = true;
                  file-manager = {
                    enable = true;
                    module = {
                      features.file-manager.fileChooser.enable = true;
                    };
                  };
                  font.enable = true;
                  greeter.enable = true;
                  media.enable = true;
                  niri = {
                    enable = true;
                    module = {
                      features.niri.noctalia.enable = true;
                    };
                  };
                  proxy = {
                    enable = true;
                    module = {
                      features.proxy = {
                        clash-verge.enable = true;
                      };
                    };
                  };
                  shell.enable = true;
                  texlive.enable = true;
                };

                users."1000" = {
                  username = "lingyu";
                  profile = config.nixosBuilderArgs.userRegistry.lingyu;

                  secrets = {
                    nutstore = {
                      user.enable = true;
                      pass.enable = true;
                    };
                    "123cloud" = {
                      user.enable = true;
                      pass.enable = true;
                    };
                    cloudflare = {
                      access_key_id.enable = true;
                      secret_access_key.enable = true;
                      endpoint.enable = true;
                    };
                    alibabacloud.oss = {
                      access_key_id.enable = true;
                      secret_access_key.enable = true;
                    };
                    deepseek.apiKey.pi.enable = true;
                    moonshot.cn.apiKey.pi.enable = true;
                    zai.cn.apiKey.pi.enable = true;
                  };

                  features = {
                    agent.enable = true;
                    diagnostics.enable = true;
                    editor = {
                      enable = true;
                      module = { pkgs, ... }: {
                        features.editor = {
                          defaultEditor = "neovim";
                          neovim.enable = true;
                          emacs.enable = true;
                          emacs.programs.package = pkgs.emacs-pgtk;
                          emacs.services.package = pkgs.emarccs-pgtk;
                          lem = {
                            enable = true;
                            package = pkgs.lem-webview;
                          };
                        };
                      };
                    };
                    file-manager.enable = true;
                    font.enable = true;
                    media.enable = true;
                    niri = {
                      enable = true;
                      module = {
                        features.niri.waybar.enable = false;
                      };
                    };
                    shell.enable = true;
                    terminal.enable = true;
                  };
                };
              };

              nixos-server = {
                host = config.nixosBuilderArgs.hostRegistry.aliyun;

                features = {
                  shell.enable = true;
                };

                workloads.caddy = {
                  enable = true;
                  module.workloads.caddy = {
                    ip = config.nixosBuilderArgs.hostTopology.aliyun.nodes.thinkbook;
                    port = 18000;
                    networkInterface = config.nixosBuilderArgs.hostTopology.aliyun.name;
                  };
                };

                users."1000" = {
                  username = "lingyu";
                  profile = config.nixosBuilderArgs.userRegistry.lingyu-minimal;

                  features = {
                    shell.enable = true;
                  };
                };
              };

              nixos-wsl = {
                host = config.nixosBuilderArgs.hostRegistry.wsl;

                features = {
                  agent.enable = true;
                  editor.enable = true;
                  file-manager = {
                    enable = true;
                    module = {
                      features.file-manager.fileChooser.enable = true;
                    };
                  };
                  font.enable = true;
                  shell.enable = true;
                  texlive.enable = true;
                };

                users."1000" = {
                  username = "lingyu";
                  profile = config.nixosBuilderArgs.userRegistry.lingyu;

                  secrets = {
                    nutstore = {
                      user.enable = true;
                      pass.enable = true;
                    };
                    "123cloud" = {
                      user.enable = true;
                      pass.enable = true;
                    };
                    cloudflare = {
                      access_key_id.enable = true;
                      secret_access_key.enable = true;
                      endpoint.enable = true;
                    };
                    alibabacloud.oss = {
                      access_key_id.enable = true;
                      secret_access_key.enable = true;
                    };
                    deepseek.apiKey.pi.enable = true;
                    moonshot.cn.apiKey.pi.enable = true;
                    zai.cn.apiKey.pi.enable = true;
                  };

                  features = {
                    agent.enable = true;
                    diagnostics.enable = true;
                    editor = {
                      enable = true;
                      module = { pkgs, ... }: {
                        features.editor = {
                          defaultEditor = "neovim";
                          neovim.enable = true;
                          emacs.enable = true;
                        };
                      };
                    };
                    file-manager.enable = true;
                    font.enable = true;
                    shell.enable = true;
                    terminal.enable = true;
                  };
                };
              };
            };

            flake = {
              nixosConfigurations = llib.flakeParts.mkNixosConfigurations {
                builderArgs = config.nixosBuilderArgs;
                configurations = config.nixosConfigurations;
              };
            };

            perSystem =
              {
                inputs',
                config,
                pkgs,
                lib,
                ...
              }:
              {
                nixpkgs.overlays = [ lpkgs.overlays.legacy ];

                legacyPackages = pkgs.legacyPackages;

                checks = import ./tests {
                  inherit lib pkgs llib;
                  modules = ./modules;
                  featureRegistry = fpArgs.config.nixosBuilderArgs.featureRegistry;
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
                    "**/flake.lock"
                    "*.age"
                    "*.patch"
                    ".gitignore"
                    "LICENSE"
                    "README.org"
                    "flake.lock"
                  ];
                };
              };
          };
        }
      );
}
