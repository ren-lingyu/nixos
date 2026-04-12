{
  
  description = "NixOS configuration";
  
  inputs = {
    nixpkgs = {
      url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-unstable&shallow=1";
      # url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    arcc-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=main&shallow=1";
      # url = "github:ren-lingyu/nixpkgs.git/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  
  outputs = { self, nixpkgs, arcc-nixpkgs, nixos-wsl, home-manager, vscode-server, ... }@inputs : let

    globalConfGenerate = { overlays ? [], unfreePackages ? [], ... } : { pkgs, lib, ... } : let

      concat = builtins.concatLists ;
      arccNixpkgsOverlay = final: prev: {
        arcc = inputs.arcc-nixpkgs.packages."${prev.system}";
      };
      allOverlays = concat [ [ arccNixpkgsOverlay ] overlays ];
      allUnfreePackages = concat [ [ "github-copilot-cli" ] unfreePackages ];
      
    in {

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "@wheel" "root" ];
      };
      nixpkgs = {
        overlays = allOverlays;
        config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) allUnfreePackages;
      };
      environment.systemPackages = with pkgs; [
        git
        vim
        curl
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
          ./modules/storage.nix
          ./modules/shell.nix
          ./modules/binary-cache.nix
          ./modules/texlive.nix
          ./modules/font.nix
          ./hosts/thinkbook
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lingyu = import ./users/lingyu;
            home-manager.extraSpecialArgs = inputs;
          }
        ];
      };

      nixos-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (globalConfGenerate {})
          ./modules/storage.nix
          ./modules/shell.nix
          ./modules/binary-cache.nix
          ./modules/texlive.nix
          ./modules/font.nix
          ./hosts/wsl
          nixos-wsl.nixosModules.default
          vscode-server.nixosModules.default
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lingyu = import ./users/lingyu;
            home-manager.extraSpecialArgs = inputs;
          }
        ];
      };

    };

  };
  
}
