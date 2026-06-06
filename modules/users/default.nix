{ config, pkgs, lib, ... } : {
  
  options = {
    modules.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (
        { name, config, ... } : {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              example = true;
              description = "Whether to enable this user.";
            };
            uid = lib.mkOption {
              type = lib.types.ints.unsigned;
              default = if builtins.match "^[0-9]+$" name != null
                        then lib.toInt name
                        else builtins.throw "`modules.users.${name}` must use a numeric UID string as its attribute name like `modules.users.\"1000\"`.";
              example = 1000;
              description = "UID of this user. Defaults to the attribute name.";
            };
            username = lib.mkOption {
              type = lib.types.str;
              default = "";
              example = "jane.doe";
              description = "Login name of this user.";
            };
            home = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = config.enable;
                example = true;
                description = "Whether to let this module manage home-related settings for this user.";
              };
              directory = lib.mkOption {
                type = lib.types.path;
                apply = toString;
                example = lib.literalExpression "/home/jane.doe";
                description = "Home directory of this user. Must be an absolute path.";
              };
              manager = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = config.home.enable;
                  example = true;
                  description = "Whether to enable Home Manager for this user.";
                };
                source = lib.mkOption {
                  type = lib.types.str;
                  default = "./${config.username}";
                  example = lib.literalExpression "./jane.doe";
                  description = "Relative path under `modules/users` to this user's Home Manager module source.";
                };
              };
            };
          };
        }
      ));
      default = {};
      example = {
        "1000" = {
          enable = true;
          uid = 1000;
          username = "jane.doe";
          home = {
            enable = true;
            directory = "/home/jane.doe";
            manager = {
              enable = true;
              source = "./jane.doe";
            };
          };
        };
      };
      description = "UID-keyed attribute set of user configurations.";
    };
  };
  
  config = {
    
    assertions = builtins.concatLists [
      
      [
        {
          assertion = let
            usersAttrSet = lib.mapAttrsToList (x_ : y_ : y_.username) (lib.filterAttrs (x_ : y_ : y_.enable) config.modules.users);
          in (builtins.length usersAttrSet) == builtins.length (lib.unique usersAttrSet);
          message = "Enabled users in `modules.users` must have unique login names.";
        }
      ]
      
      (builtins.concatLists (lib.mapAttrsToList (uidKey_ : user_ : [          
        {
          assertion = builtins.match "^[0-9]+$" uidKey_ != null;
          message = "`modules.users.${uidKey_}` must use a numeric UID string as its attribute name, like `modules.users.\"1000\"`.";
        }
        {
          assertion = (builtins.match "^[0-9]+$" uidKey_ != null) && (user_.uid == lib.toInt uidKey_);
          message = "`modules.users.${uidKey_}.uid` must equal ${uidKey_}.";
        }
        {
          assertion = (!user_.enable) || ((builtins.match "^[0-9]+$" uidKey_ != null) && (user_.uid >= 1000));
          message = "`modules.users.${uidKey_}.uid` must be greater than or equal to 1000 when this user is enabled.";
        }
        {
          assertion = !user_.enable || user_.username != "";
          message = "`modules.users.${uidKey_}.username` must not be empty when this user is enabled.";
        }
        {
          assertion = !user_.home.enable || user_.enable;
          message = "`modules.users.${uidKey_}.home.enable = true` requires `modules.users.${uidKey_}.enable = true`.";
        }
        {
          assertion = !user_.home.enable || lib.hasPrefix "/" (builtins.toString user_.home.directory);
          message = "`modules.users.${uidKey_}.home.directory` must be an absolute path when `modules.users.${uidKey_}.home.enable = true`.";
        }
        {
          assertion = !user_.home.manager.enable || user_.home.enable;
          message = "`modules.users.${uidKey_}.home.manager.enable = true` requires `modules.users.${uidKey_}.home.enable = true`.";
        }
        {
          assertion = let
            basePathString = builtins.unsafeDiscardStringContext (builtins.toString ./.);
            sourcePathString = builtins.unsafeDiscardStringContext (builtins.toString (./. + "/${user_.home.manager.source}"));
          in !user_.home.manager.enable || lib.hasPrefix "${basePathString}/" sourcePathString;
          message = "`modules.users.${uidKey_}.home.manager.source` must resolve under `${builtins.toString ./.}`.";
        }
        {
          assertion = !user_.home.manager.enable || builtins.pathExists (./. + "/${builtins.toString user_.home.manager.source}/default.nix");
          message = "`modules.users.${uidKey_}.home.manager.enable = true` requires `${builtins.toString (./. + "/${builtins.toString user_.home.manager.source}/default.nix")}` to exist.";
        }
      ]) config.modules.users ))
      
    ];
    
    users.users = builtins.listToAttrs (lib.mapAttrsToList (uidKey_ : user_ : {
      name = builtins.toString uidKey_;
      value = lib.mkMerge [
        {
          isNormalUser = lib.mkForce true;
          uid = lib.mkForce user_.uid;
          name = lib.mkForce user_.username;
        }
        (lib.mkIf user_.home.enable {
          createHome = lib.mkForce user_.home.enable;
          home = lib.mkForce (builtins.toString user_.home.directory);
        })
      ];
    }) (lib.filterAttrs (x_ : y_ : y_.enable) config.modules.users));

    home-manager.users = builtins.listToAttrs (lib.mapAttrsToList (uidKey_ : user_ : {
      name = builtins.toString uidKey_;
      value = {
        imports = [
          (./. + "/${builtins.toString user_.home.manager.source}")
        ];
        home = {
          uid = lib.mkForce user_.uid;
          username = lib.mkForce user_.username;
          homeDirectory = lib.mkForce (builtins.toString user_.home.directory);
        };
      };
    }) (lib.filterAttrs (x_ : y_ : (y_.enable && y_.home.enable && y_.home.manager.enable)) config.modules.users));
    
  };
  
}
