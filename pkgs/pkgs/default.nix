{
  lib,
  llib,
  overlays,
}:
{
  overlays = llib.packages.mkOverlays {
    root = ./.;
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
          zotero
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
  };

  nixosModule = llib.packages.mkNixosModule {
    root = ./.;
    modulePath = "os/default.nix";
  };

  homeModule = llib.packages.mkHomeModule {
    root = ./.;
    modulePath = "hm/default.nix";
  };
}
