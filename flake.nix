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
    efitools-pr = {
      url = "github:NixOS/nixpkgs/refs/pull/514576/head";
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
      inputs.nixpkgs.follows = "nixpkgs";
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
  };
  
  outputs = { self, ... }@inputs : let

    globalConfGenerate = { overlays ? [], unfreePackages ? [], ... } : { pkgs, lib, ... } : let

      concat = builtins.concatLists ;
      arccNixpkgsOverlay = final: prev: {
        arcc = inputs.arcc-nixpkgs.packages."${prev.system}";
      };
      efitoolsOverlay =  final: prev: {
        efitools = inputs.efitools-pr.legacyPackages."${prev.system}".efitools;
      };
      allOverlays = concat [
        [
          arccNixpkgsOverlay
          inputs.niri-flake.overlays.niri
          efitoolsOverlay
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
        gzip
      ];

    };
    
  in {
    
    nixosConfigurations = {

      nixos = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (globalConfGenerate {
            unfreePackages = [
              "microsoft-edge"
              "feishu"
            ];
          })
          inputs.nix-flatpak.nixosModules.nix-flatpak
          ./modules/hosts/thinkbook
          inputs.home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lingyu = {
                imports = [
                  ./modules/users/lingyu
                  ./modules/niri/home
                  ./modules/secret/home.nix
                ];
              };
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
                inputs.nixvim.homeModules.nixvim
                inputs.niri-flake.homeModules.niri
                inputs.noctalia-shell.homeModules.default
              ];
              extraSpecialArgs = {
                inherit inputs;
              };
            };
          }
          inputs.sops-nix.nixosModules.sops
          ./modules/secret
          ./modules/shell.nix
          ./modules/texlive.nix
          ./modules/font.nix
          ./modules/media.nix
          ./modules/niri/conf
        ];
      };

      nixos-wsl = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (globalConfGenerate {})
          inputs.nixos-wsl.nixosModules.default
          inputs.vscode-server.nixosModules.default
          ./modules/hosts/wsl
          inputs.home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lingyu = {
                imports = [
                  ./modules/users/lingyu
                  ./modules/secret/home.nix
                ];
              };
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
                inputs.nixvim.homeModules.nixvim
              ];
              extraSpecialArgs = {
                inherit inputs;
              };
            };
          }
          inputs.sops-nix.nixosModules.sops
          ./modules/secret
          ./modules/shell.nix
          ./modules/texlive.nix
          ./modules/font.nix
        ];
      };

    };

  };
  
}
