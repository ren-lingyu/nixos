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
      url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-unstable&shallow=1";
      # url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    arcc-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager.git?ref=master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      # the main branch of nixvim must be use in nixos-unstable
      url = "git+https://github.com/nix-community/nixvim.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "git+https://github.com/nix-community/NixOS-WSL.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "git+https://github.com/nix-community/nixos-vscode-server.git?ref=master&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "git+https://github.com/sodiboo/niri-flake.git?ref=main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-shell = {
      url = "git+https://github.com/noctalia-dev/noctalia-shell.git?ref=refs/heads/main&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "git+https://github.com/gmodena/nix-flatpak.git?ref=refs/tags/latest&shallow=1";
    };

  };
  
  outputs = { self, nixpkgs, arcc-nixpkgs, home-manager, nixvim, nixos-wsl, vscode-server, niri-flake, nix-flatpak, ... }@inputs : let

    globalConfGenerate = { overlays ? [], unfreePackages ? [], ... } : { pkgs, lib, ... } : let

      concat = builtins.concatLists ;
      arccNixpkgsOverlay = final: prev: {
        arcc = inputs.arcc-nixpkgs.packages."${prev.system}";
      };
      allOverlays = concat [
        [
          arccNixpkgsOverlay
          inputs.niri-flake.overlays.niri
        ]
        overlays
      ];
      allUnfreePackages = concat [ [ "github-copilot-cli" ] unfreePackages ];
      
    in {
      
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      
      nixpkgs = {
        overlays = allOverlays;
        config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) allUnfreePackages;
      };
      
      environment.systemPackages = with pkgs; [
        git
        vim
        curl
        wget
        gnutar
      ];

    };
      
  in {
    
    nixosConfigurations = {

      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (globalConfGenerate {
            unfreePackages = [
              "microsoft-edge"
              "feishu"
            ];
          })
          ./modules/shell.nix
          ./modules/texlive.nix
          ./modules/font.nix
          ./modules/media.nix
          ./hosts/thinkbook
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lingyu = {
                imports = [
                  ./users/lingyu
                  ./modules/niri/home
                ];
              };
              extraSpecialArgs = {
                nixvim = inputs.nixvim;
                niri-flake = inputs.niri-flake;
                noctalia-shell = inputs.noctalia-shell;
                # inherit inputs;
              };
            };
          }
        ];
      };

      nixos-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (globalConfGenerate {})
          ./modules/shell.nix
          ./modules/texlive.nix
          ./modules/font.nix
          ./hosts/wsl
          nixos-wsl.nixosModules.default
          vscode-server.nixosModules.default
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lingyu = {
                imports = [
                  ./users/lingyu
                ];
              };
              extraSpecialArgs = {
                nixvim = inputs.nixvim;
                # inherit inputs;
              };
            };
          }
        ];
      };

    };

  };
  
}
