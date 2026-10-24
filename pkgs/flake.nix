{
  description = "Local nixpkgs used by the nixos configuration";

  nixConfig = {
    auto-optimise-store = true;
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs?ref=refs/heads/nixpkgs-unstable&shallow=1";
    };
    personal-nixpkgs = {
      url = "git+https://github.com/ren-lingyu/nixpkgs?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        local-nixpkgs.url = "git+https://github.com/ren-lingyu/nixpkgs?ref=refs/heads/main&shallow=1&dir=pkgs";
      };
    };
    emarccs = {
      url = "git+https://github.com/ren-lingyu/emarccs.git?ref=refs/heads/main&rev=c54849019abba42bb5feeabd71548958fe0f0407&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "personal-nixpkgs/flake-parts";
        treefmt-nix.follows = "personal-nixpkgs/treefmt-nix";
        # personal-nixpkgs.follows = "personal-nixpkgs";
      };
    };
    nixvim = {
      # the main branch of nixvim must be use in nixpkgs-unstable
      url = "git+https://github.com/nix-community/nixvim.git?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "personal-nixpkgs/flake-parts";
      };
    };
    lem = {
      url = "git+https://github.com/lem-project/lem.git?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "personal-nixpkgs/flake-parts";
      };
    };
    lean4-nix = {
      url = "git+https://github.com/lenianiva/lean4-nix.git?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "personal-nixpkgs/flake-parts";
      };
    };
    git-agent-workflow = {
      url = "git+https://github.com/ren-lingyu/git-agent-workflow.git?ref=refs/heads/main&shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "personal-nixpkgs/flake-parts";
      };
    };
    zotero-fix-nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?rev=363fdbe57ed052c76e816e6270206b0cb348e53a&shallow=1";
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
        lpkgs = import ./pkgs { inherit llib; };
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
                share = lpkgs.nixosModule;
              };

              homeModules = {
                share = lpkgs.homeModule;
                editor = inputs.nixvim.homeModules.nixvim;
              };

              overlays = builtins.mapAttrs (_: value_: lib.composeManyExtensions value_) {
                legacy = [ lpkgs.overlays.legacy ];

                share = [
                  inputs.git-agent-workflow.overlays.default
                  (final_: prev_: {
                    lean4 = inputs.lean4-nix.packages.${final_.stdenv.hostPlatform.system}.lean-bin;
                    zotero = inputs.zotero-fix-nixpkgs.legacyPackages.${final_.stdenv.hostPlatform.system}.zotero;
                  })
                  lpkgs.overlays.share
                ];

                editor = [
                  inputs.emarccs.overlays.default
                  inputs.lem.overlays.default
                  (
                    final_: prev_:
                    let
                      lem = prev_.lem-webview.overrideLispAttrs (old: {
                        lispLibs = builtins.concatLists [
                          old.lispLibs
                          [ final_.sbclPackages.cl-template ]
                        ];
                      });
                    in
                    {
                      lem-webview = final_.symlinkJoin {
                        name = "${lem.name}-with-desktop";
                        paths = [
                          lem
                          (final_.writeTextFile {
                            name = "lem-desktop";
                            destination = "/share/applications/lem.desktop";
                            text = builtins.replaceStrings [ "/usr/local/bin/lem -i webview" ] [ "${final_.lib.getExe lem}" ] (
                              builtins.readFile "${inputs.lem}/scripts/install/lem-webview.desktop"
                            );
                          })
                          (final_.writeTextFile {
                            name = "lem-icon";
                            destination = "/share/icons/hicolor/scalable/apps/lem.svg";
                            text = builtins.readFile "${inputs.lem}/scripts/install/lem.svg";
                          })
                        ];
                        meta = lem.meta;
                      };
                    }
                  )
                ];
              };
            };
          };
        }
      );
}
