{ options, config, pkgs, lib, ... } : let
  
  overlaysList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : ((type_ == "directory") && (builtins.pathExists (./. + "/${name_}/default.nix")))) (builtins.readDir ./.));
  
in {

  imports = (builtins.map (x_ : ./. + "/${x_}") overlaysList_);
  
  options = {
    modules.overlays = (builtins.listToAttrs (builtins.map (overlay_ : {
      name = overlay_;
      value = let
        possibleExtraOptionsPath_ = ./. + "/${builtins.toString overlay_}/extra-options.nix";
      in {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to enable the ${overlay_} overlay.";
        }; 
      } // (lib.optionalAttrs (builtins.pathExists possibleExtraOptionsPath_) (
        (import possibleExtraOptionsPath_) overlay_ {
          inherit options;
          inherit config;
          inherit pkgs;
          inherit lib;
        }
      ));
    }) overlaysList_));
  };

}
