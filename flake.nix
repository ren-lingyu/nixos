{
  description = "NixOS configuration";
  inputs = {
    nixpkgs = {
      url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-unstable&shallow=1";
      # type = "github";
      # owner = "NixOS";
      # repo = "nixpkgs";
      # ref = "nixos-unstable";
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
  outputs = { self, nixpkgs, nixos-wsl, home-manager, vscode-server, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-wsl.nixosModules.default
	vscode-server.nixosModules.default
        ./configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.lingyu = import ./home/lingyu;
	  home-manager.extraSpecialArgs = inputs;
	}
      ];
    };
  };
}
