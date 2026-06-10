{ config, pkgs, lib, ... } : let
  
  allowFeatureList = builtins.attrNames (lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./.));
  
in {
  
  options = {
    
    modules.features = (builtins.listToAttrs (builtins.map (feature_: {
      
      name = feature_;
      
      value = {
        
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to enable the ${feature_} feature.";
        };
        
        allowUidList = lib.mkOption {
          type = lib.types.listOf lib.types.ints.unsigned;
          default =
            if config.modules.features."${feature_}".existModule.hm
            then [ 1000 ]
            else [];
          example = [ 1000 1001 ];
          description = "User UIDs whose Home Manager configurations should import the ${feature_} module.";
        };
        
        existModule = {
          os = lib.mkOption {
            type = lib.types.unique {
              message = "Only one module may define `modules.features.${feature_}.existModule.os`.";
            } lib.types.bool;
            internal = true;
            default = false;
            example = true;
            description = "Whether this feature has an OS module.";
          };
          hm = lib.mkOption {
            type = lib.types.unique {
              message = "Only one module may define `modules.features.${feature_}.existModule.hm`.";
            } lib.types.bool;
            internal = true;
            default = false;
            example = true;
            description = "Whether this feature has a Home Manager module.";
          };
        };
        
      } // (lib.optionalAttrs (feature_ == "niri") {
        
        noctalia.enable = lib.mkOption {
          type = lib.types.bool;
          default = config.modules.features.${feature_}.enable;
          example = true;
          description = "Whether to enable the Noctalia shell configuration for Niri.";
        };

        waybar.enable = lib.mkOption {
          type = lib.types.bool;
          default =
            !config.modules.features.${feature_}.noctalia.enable
            && config.modules.features.${feature_}.enable;
          example = false;
          description = "Whether to enable the Waybar status bar for Niri.";
        };

        greeter.enable = lib.mkOption {
          type = lib.types.bool;
          default = config.modules.features.${feature_}.enable;
          example = true;
          description = "Whether to enable the greeter (display manager) for Niri.";
        };

        monitor = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "eDP-1";
            example = "eDP-1";
            description = "Name of the primary monitor for Niri output configuration.";
          };
          width = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 3072;
            example = 3072;
            description = "Width of the primary monitor in pixels.";
          };
          height = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 1920;
            example = 1920;
            description = "Height of the primary monitor in pixels.";
          };
        };
        
      });
      
    }) allowFeatureList));
    
  };
  
  config = {
    
    assertions = builtins.concatLists (lib.mapAttrsToList (featureName_ : feature_ : (lib.optionals (feature_.enable && feature_.existModule.hm) [
      {
        assertion = (!feature_.enable) || (!feature_.existModule.hm) || (builtins.all (uid_ : let
          uidKey_ = builtins.toString uid_;
        in (
          (builtins.hasAttr uidKey_ config.modules.users) && (config.modules.users."${uidKey_}".enable) && (config.modules.users."${uidKey_}".home.manager.enable)
        )) feature_.allowUidList);
        message = "`modules.features.${featureName_}.allowUidList` must only contain UIDs declared in `modules.users`, and each listed user must have `enable = true` and `home.manager.enable = true`."; 
      }
    ])) config.modules.features);
    
    home-manager.users = builtins.mapAttrs (uidKey_ : imports_ : {
      imports = imports_;
    }) (lib.foldlAttrs (x_ : featureName_ : feature_ : (builtins.foldl' (y_ : uid_ : (let
      homeManagerModulePath_ = ./. + "/${featureName_}/hm";
      uidString_ = builtins.toString uid_;
    in (
      if builtins.hasAttr uidString_ y_
      then y_ // { "${uidString_}" = [ homeManagerModulePath_ ] ++ y_."${uidString_}"; }
      else y_ // { "${uidString_}" = [ homeManagerModulePath_ ]; }
    ))) x_ (lib.optionals (feature_.enable && feature_.existModule.hm) feature_.allowUidList))) {} config.modules.features);
    
  };
  
}
