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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        personal-nixpkgs.follows = "personal-nixpkgs";
      };
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
    };
    disko = {
      # url = "git+https://github.com/nix-community/disko.git?ref=refs/heads/master&shallow=1";
      follows = "nixos-anywhere/disko";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.personal-nixpkgs.lib.mkFlake inputs.nixpkgs
      ({ lib }: {
        inherit inputs;
        moduleLocation = __curPos.file;
        llib = inputs.personal-nixpkgs.lib.mergeAttrsRecursive { allowOverrides = false; } [
          {
            inherit (inputs.personal-nixpkgs.lib) tests;
            inherit (import ./pkgs/lib { inherit lib; }) types;
          }
          (import ./lib { inherit lib; })
        ];
        specialArgs = {
          rootPath = ./.;
        };
      })
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
                agent = {
                  nixosModules = [
                    inputs.local-nixpkgs.nixosModules.agent
                    { features.agent.enable = true; }
                  ];
                  homeModules = [
                    inputs.local-nixpkgs.homeModules.agent
                    ({ config, options, ... }: {
                      features.agent.enable = true;
                      features.agent.pi.providers = lib.mapAttrs (
                        name: provider:
                        let
                          source = options.moduleInterfaces.features.agent.pi.providers.${name};
                        in
                        lib.optionalAttrs source.enable.isDefined { inherit (provider) enable; }
                        // lib.optionalAttrs source.apiKey.isDefined { apiKeyFile = provider.apiKey; }
                      ) config.moduleInterfaces.features.agent.pi.providers;
                    })
                  ];
                };
                diagnostics.homeModules = [
                  inputs.local-nixpkgs.homeModules.diagnostics
                  { features.diagnostics.enable = true; }
                ];
                editor = {
                  nixpkgsOverlays = [ inputs.local-nixpkgs.overlays.editor ];
                  homeModules = [
                    inputs.local-nixpkgs.homeModules.editor
                    ({ osConfig, ... }: {
                      features.editor = {
                        enable = true;
                        inherit (osConfig.modules.features.editor)
                          defaultEditor
                          vim
                          neovim
                          emacs
                          lem
                          ;
                      };
                    })
                  ];
                };
                file-manager = {
                  nixosModules = [
                    inputs.local-nixpkgs.nixosModules.file-manager
                    ({ config, ... }: {
                      features.file-manager.enable = true;
                      features.file-manager.fileChooser = config.modules.features.file-manager.fileChooser;
                    })
                  ];
                  homeModules = [
                    inputs.local-nixpkgs.homeModules.file-manager
                    ({ osConfig, ... }: {
                      features.file-manager = {
                        enable = true;
                        inherit (osConfig.modules.features.file-manager) fileChooser;
                        wayfile.enable = osConfig.modules.features.niri.enable;
                      };
                    })
                  ];
                };
                font = {
                  nixosModules = [
                    inputs.local-nixpkgs.nixosModules.font
                    { features.font.enable = true; }
                  ];
                  homeModules = [
                    inputs.local-nixpkgs.homeModules.font
                    { features.font.enable = true; }
                  ];
                };
                greeter.nixosModules = [
                  inputs.local-nixpkgs.nixosModules.greeter
                  (
                    { config, ... }:
                    let
                      host = llib.hosts.getUniqueEnabledHost config.modules.hosts;
                      defaults = lib.filter (monitor: monitor.role == "default") (lib.attrValues host.monitors);
                    in
                    {
                      features.greeter = {
                        enable = true;
                        monitorName = (builtins.head defaults).name;
                        sessionPackages = lib.mkMerge [
                          (lib.mkIf (config.features.niri.enable or false) (
                            lib.mkBefore [ config.features.niri.sessionPackage ]
                          ))
                          (lib.mkIf (config.features.x11-session.enable or false) [
                            config.features.x11-session.sessionPackage
                          ])
                        ];
                      };
                    }
                  )
                ];
                media = {
                  nixosModules = [
                    inputs.local-nixpkgs.nixosModules.media
                    { features.media.enable = true; }
                  ];
                  homeModules = [
                    inputs.local-nixpkgs.homeModules.media
                    { features.media.enable = true; }
                  ];
                };
                niri = {
                  nixpkgsOverlays = [ inputs.niri-flake.overlays.niri ];
                  nixosModules = [
                    inputs.local-nixpkgs.nixosModules.niri
                    ({ config, ... }: {
                      features.niri = {
                        enable = true;
                        inherit (config.modules.features.niri) noctalia;
                      };
                    })
                  ];
                  homeModules = [
                    inputs.niri-flake.homeModules.niri
                    inputs.local-nixpkgs.homeModules.niri
                    ({ osConfig, ... }: {
                      features.niri = {
                        enable = true;
                        inherit (osConfig.modules.features.niri) noctalia waybar;
                        inherit (llib.hosts.getUniqueEnabledHost osConfig.modules.hosts) monitors;
                      };
                    })
                  ];
                };
                office.homeModules = [
                  inputs.local-nixpkgs.homeModules.office
                  { features.office.enable = true; }
                ];
                proxy.nixosModules = [
                  inputs.local-nixpkgs.nixosModules.proxy
                  ({ config, ... }: {
                    features.proxy = {
                      enable = true;
                      inherit (config.modules.features.proxy)
                        clash-verge
                        throne
                        mihomo
                        v2raya
                        ;
                    };
                  })
                ];
                shell = {
                  nixosModules = [
                    inputs.local-nixpkgs.nixosModules.shell
                    { features.shell.enable = true; }
                  ];
                  homeModules = [
                    inputs.local-nixpkgs.homeModules.shell
                    { features.shell.enable = true; }
                  ];
                };
                sops = {
                  nixosModules = [
                    inputs.sops-nix.nixosModules.sops
                    inputs.local-nixpkgs.nixosModules.sops
                    ({ config, ... }: {
                      features.sops = {
                        enable = true;
                        authorizedUids = config.modules.features.sops.allowUidList;
                      };
                    })
                  ];
                  homeModules = [
                    inputs.sops-nix.homeManagerModules.sops
                    inputs.local-nixpkgs.homeModules.sops
                    (
                      {
                        config,
                        options,
                        osConfig,
                        ...
                      }:
                      let
                        source = options.moduleInterfaces.features.sops;
                        values = config.moduleInterfaces.features.sops;
                      in
                      {
                        features.sops = {
                          enable = true;
                          ageKeyPath = osConfig.age.secrets."sops.hm".path;
                        }
                        // lib.optionalAttrs source.secretsInput.isDefined { inherit (values) secretsInput; }
                        // lib.optionalAttrs source.defaultSopsFormat.isDefined { inherit (values) defaultSopsFormat; }
                        // lib.optionalAttrs source.defaultSopsFile.isDefined { inherit (values) defaultSopsFile; };
                      }
                    )
                  ];
                };
                terminal.homeModules = [
                  inputs.local-nixpkgs.homeModules.terminal
                  { features.terminal.enable = true; }
                ];
                texlive.nixosModules = [
                  inputs.local-nixpkgs.nixosModules.texlive
                  { features.texlive.enable = true; }
                ];
                x11-session = {
                  nixosModules = [
                    inputs.local-nixpkgs.nixosModules.x11-session
                    { features.x11-session.enable = true; }
                  ];
                  homeModules = [
                    inputs.local-nixpkgs.homeModules.x11-session
                    { features.x11-session.enable = true; }
                  ];
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
                    ip = { config, ... }: config.networking.wireguard.topology.aliyun.nodes.thinkbook;
                    port = _: 18000;
                    networkInterface = { config, ... }: config.networking.wireguard.topology.aliyun.name;
                    allowedSourceIp = { config, ... }: config.networking.wireguard.topology.aliyun.nodes.aliyun;
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
                    ip = { config, ... }: config.networking.wireguard.topology.aliyun.nodes.thinkbook;
                    port = _: 18000;
                    networkInterface = { config, ... }: config.networking.wireguard.topology.aliyun.name;
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

                checks =
                  import ./tests {
                    inherit lib pkgs llib;
                    modules = ./modules;
                  }
                  // {
                    inherit (inputs.local-nixpkgs.checks.${system})
                      feature-discovery
                      native-feature-enables
                      sops-functions
                      ;
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
