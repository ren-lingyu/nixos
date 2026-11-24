{
  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=refs/heads/nixpkgs-unstable&shallow=1";
    };
    personal-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs.git?ref=refs/heads/main&shallow=1";
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
    zotero-fix-nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?rev=363fdbe57ed052c76e816e6270206b0cb348e53a&shallow=1";
    };
    keep-a-changelog = {
      url = "git+https://github.com/olivierlacan/keep-a-changelog.git?rev=5417981223f2e87fb2c94e9c57a6c0b011447306&shallow=1";
      flake = false;
    };
    semver-org = {
      url = "git+https://github.com/semver/semver.org.git?rev=839c747aeb15078beea00dbe93a84f2c0fd39878&shallow=1";
      flake = false;
    };
    wayfile = {
      url = "git+https://github.com/blackbartblues/Wayfile.git?rev=e03db0c44d84aab3d3d67f6ae4b8fb6f9b3ae482&shallow=1&submodules=1";
      flake = false;
    };
    luadraw = {
      url = "git+https://github.com/pfradin/luadraw.git?rev=eba63b144ba788209191a611f461cd65a5e8935a&shallow=1";
      flake = false;
    };
    pi-agentic-search = {
      url = "git+https://github.com/dantetekanem/pi-agentic-search.git?rev=fda2434bdfc9ffc810c145f66dc552c2464f1614&shallow=1";
      flake = false;
    };
    pi-mono-extensions = {
      url = "git+https://github.com/emanuelcasco/pi-mono-extensions.git?rev=e4e047a5a203cac78f5e420c92a3115ccd2fe6bb&shallow=1";
      flake = false;
    };
    pi-workspace-history = {
      url = "git+https://github.com/wcldyx/pi-workspace-history.git?rev=4c51d3cad723bd8733c73fb36f4b971efb2eb53a&shallow=1";
      flake = false;
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.personal-nixpkgs.lib.mkFlake inputs.nixpkgs
      ({ lib }: rec {
        inherit inputs;
        moduleLocation = __curPos.file;
        llib = inputs.personal-nixpkgs.lib.mergeAttrsRecursive { allowOverrides = false; } [
          { inherit (inputs.personal-nixpkgs.lib) packages; }
          (import ./lib { inherit lib; })
        ];
        lpkgs = import ./pkgs {
          inherit lib llib;
          sources = {
            inherit (inputs)
              keep-a-changelog
              semver-org
              wayfile
              luadraw
              pi-agentic-search
              pi-mono-extensions
              pi-workspace-history
              ;
          };
          overlays = {
            emarccs = inputs.emarccs.overlays.default;
            git-agent-workflow = inputs.git-agent-workflow.overlays.default;
            lean4 = final_: prev_: {
              lean4 = inputs.lean4-nix.packages.${final_.stdenv.hostPlatform.system}.lean-bin;
            };
            lem = inputs.lem.overlays.default;
            zotero = final_: prev_: {
              zotero = inputs.zotero-fix-nixpkgs.legacyPackages.${final_.stdenv.hostPlatform.system}.zotero;
            };
          };
        };
      })
      (
        {
          llib,
          lpkgs,
          config,
          lib,
          ...
        }:
        {
          config = {
            debug = true;

            systems = [ "x86_64-linux" ];

            flake = {
              nixosModules = {
                agent = ./modules/agent/os;
                editor = { config, lib, ... }: {
                  imports = [ ./modules/editor/os ];

                  config = lib.mkIf config.features.editor.enable { nixpkgs.overlays = [ lpkgs.overlays.editor ]; };
                };
                file-manager = ./modules/file-manager/os;
                font = ./modules/font/os;
                greeter = ./modules/greeter/os;
                media = ./modules/media/os;
                niri = { config, lib, ... }: {
                  imports = [ ./modules/niri/os ];

                  config = lib.mkIf config.features.niri.enable {
                    nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];
                  };
                };
                proxy = ./modules/proxy/os;
                share = lpkgs.nixosModule;
                shell = ./modules/shell/os;
                sops.imports = [
                  inputs.sops-nix.nixosModules.sops
                  ./modules/sops/os
                ];
                texlive = ./modules/texlive/os;
                x11-session = ./modules/x11-session/os;
              };

              homeModules = {
                agent = ./modules/agent/hm;
                diagnostics = ./modules/diagnostics/hm;
                editor.imports = [
                  inputs.nixvim.homeModules.nixvim
                  ./modules/editor/hm
                ];
                file-manager = ./modules/file-manager/hm;
                font = ./modules/font/hm;
                media = ./modules/media/hm;
                niri.imports = [
                  inputs.niri-flake.homeModules.niri
                  ./modules/niri/hm
                ];
                office = ./modules/office/hm;
                share = lpkgs.homeModule;
                shell = ./modules/shell/hm;
                sops.imports = [
                  inputs.sops-nix.homeManagerModules.sops
                  ./modules/sops/hm
                ];
                terminal = ./modules/terminal/hm;
                x11-session = ./modules/x11-session/hm;
              };

              overlays = {
                editor = lpkgs.overlays.editor;
                legacy = lpkgs.overlays.legacy;
                share = lpkgs.overlays.share;
              };
            };

            perSystem = { pkgs, ... }: {
              checks = {
                native-feature-enables = import ./tests/native-feature-enables.nix {
                  inherit lib pkgs;
                  # The fixture supplies native declarations instead of upstream modules.
                  nixosModules = builtins.removeAttrs config.flake.nixosModules [ "share" ] // {
                    sops = ./modules/sops/os;
                  };
                  homeModules = builtins.removeAttrs config.flake.homeModules [ "share" ] // {
                    editor = ./modules/editor/hm;
                    niri = ./modules/niri/hm;
                    sops = ./modules/sops/hm;
                  };
                };
                sops-functions = import ./tests/sops-functions.nix {
                  inherit lib;
                  inherit (pkgs) runCommand;
                  secrets = import ./modules/sops/hm/secrets.nix;
                  sops = ./modules/sops/os;
                };
              };
            };
          };
        }
      );
}
