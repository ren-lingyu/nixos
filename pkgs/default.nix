{
  lib,
  llib,
  overlays,
}:
{
  overlays = llib.packages.mkOverlays {
    root = ./pkgs;
    overlayFile = "overlay.nix";
    groups = {
      legacy = {
        export = true;
        overlays = lib.mapAttrsToList (_: value_: value_) overlays;
      };

      share = {
        exclude = [ "rage-armored" ];
        overlays = with overlays; [
          git-agent-workflow
          lean4
        ];
      };

      editor = {
        include = [ ];
        overlays = with overlays; [
          emarccs
          lem
        ];
      };
    };
    extraArgs.sources = (builtins.getFlake ./srcs).inputs;
  };

  nixosModule = llib.packages.mkNixosModule {
    root = ./pkgs;
    modulePath = "os/default.nix";
  };

  homeModule = llib.packages.mkHomeModule {
    root = ./pkgs;
    modulePath = "hm/default.nix";
  };
}
