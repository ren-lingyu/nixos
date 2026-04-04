{
  description = "NixOS configuration";
  
  inputs = {
    nixpkgs = {
      url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-unstable&shallow=1";
      # type = "github";
      # owner = "NixOS";
      # repo = "nixpkgs";
      # ref = "nixos-unstable";
    };
    arcc-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=main&shallow=1";
      # type = "github";
      # owner = "ren-lingyu";
      # repo = "nixpkgs";
      # ref = "main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      type = "github";
      owner = "nix-community";
      repo = "NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      type = "github";
      owner = "nix-community";
      repo = "home-manager";    
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      type = "github";
      owner = "nix-community";
      repo = "nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, arcc-nixpkgs, nixos-wsl, home-manager, vscode-server, ... }@inputs: {
    nixosConfigurations = {
      # config on WSL2, set hostname as nixos for convience. 
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({pkgs, ...} : {
            nixpkgs.overlays = [
              (final: prev: {arcc-nixpkgs = inputs.arcc-nixpkgs.packages."${prev.system}";})
            ];
          })
          ./configuration.nix # the minimal configuration
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
