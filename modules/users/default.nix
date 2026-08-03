{ config, pkgs, lib, ... } : let

  usersList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : ((type_ == "directory") && (builtins.pathExists (./. + "/${name_}/default.nix")))) (builtins.readDir ./.));

in {

  options = {
    modules.users = builtins.listToAttrs (builtins.map (userName_ : {
      name = userName_;
      value = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to enable the ${userName_} user profile.";
        };
        uid = lib.mkOption {
          type = lib.types.unique {
            message = "Conflicting UID assignments for `modules.users.${userName_}.uid`.";
          } (lib.types.nullOr lib.types.ints.unsigned);
          default = null;
          internal = true;
          example = 1000;
          description = "UID assigned to the ${userName_} user profile by the final flake composition.";
        };
        username = lib.mkOption {
          type = lib.types.str;
          default = userName_;
          example = "jane.doe";
          description = "Login name of the ${userName_} user profile.";
        };
        home = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = config.modules.users.${userName_}.enable;
            example = true;
            description = "Whether to manage home-related settings for the ${userName_} user profile.";
          };
          directory = lib.mkOption {
            type = lib.types.path;
            apply = toString;
            example = lib.literalExpression "/home/jane.doe";
            description = "Home directory of the ${userName_} user profile. Must be an absolute path.";
          };
          manager = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = config.modules.users.${userName_}.home.enable;
              example = true;
              description = "Whether to enable Home Manager for the ${userName_} user profile.";
            };
            source = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = "./${userName_}";
              example = lib.literalExpression "./jane.doe";
              description = "Relative path under `modules/users` to the ${userName_} Home Manager module source.";
            };
          };
        };
      };
    }) usersList_);
  };

  config = {

    assertions = let
      enabledUsers_ = lib.filterAttrs (unused_name_ : user_ : user_.enable) config.modules.users;
      enabledUserUids_ = builtins.map (user_ : user_.uid) (builtins.attrValues enabledUsers_);
      assignedUserUids_ = builtins.filter (uid_ : uid_ != null) (builtins.map (user_ : user_.uid) (builtins.attrValues config.modules.users));
    in builtins.concatLists [

      [
        {
          assertion = let usernames_ = builtins.map (user_ : user_.username) (builtins.attrValues enabledUsers_);
          in (builtins.length usernames_) == builtins.length (lib.unique usernames_);
          message = "Enabled users in `modules.users` must have unique login names.";
        }
        {
          assertion = (builtins.length assignedUserUids_) == (builtins.length (lib.unique assignedUserUids_));
          message = "Assigned UIDs in `modules.users` must be unique.";
        }
      ]

      (builtins.concatLists (lib.mapAttrsToList (userName_ : user_ : [
        {
          assertion = user_.enable == (user_.uid != null);
          message = "`modules.users.${userName_}.enable` must be true exactly when `modules.users.${userName_}.uid` is assigned by the final flake composition.";
        }
        {
          assertion = user_.uid == null || user_.uid >= 1000;
          message = "`modules.users.${userName_}.uid` must be greater than or equal to 1000 when assigned.";
        }
        {
          assertion = !user_.enable || user_.username != "";
          message = "`modules.users.${userName_}.username` must not be empty when this user is enabled.";
        }
        {
          assertion = !user_.home.enable || user_.enable;
          message = "`modules.users.${userName_}.home.enable = true` requires `modules.users.${userName_}.enable = true`.";
        }
        {
          assertion = !user_.home.enable || lib.hasPrefix "/" (builtins.toString user_.home.directory);
          message = "`modules.users.${userName_}.home.directory` must be an absolute path when `modules.users.${userName_}.home.enable = true`.";
        }
        {
          assertion = !user_.home.manager.enable || user_.home.enable;
          message = "`modules.users.${userName_}.home.manager.enable = true` requires `modules.users.${userName_}.home.enable = true`.";
        }
        {
          assertion = if (user_.home.manager.source != null)
                      then (let
                        basePathString = builtins.unsafeDiscardStringContext (builtins.toString ./.);
                        sourcePathString = builtins.unsafeDiscardStringContext (builtins.toString (./. + "/${user_.home.manager.source}"));
                      in !user_.home.manager.enable || lib.hasPrefix "${basePathString}/" sourcePathString)
                      else !user_.home.manager.enable || (user_.home.manager.source == null);
            message = "`modules.users.${userName_}.home.manager.source` must be `null` or resolve under `${builtins.toString ./.}`.";
        }
        {
          assertion = if (user_.home.manager.source != null)
                      then !user_.home.manager.enable || builtins.pathExists (./. + "/${builtins.toString user_.home.manager.source}/default.nix")
                      else !user_.home.manager.enable || (user_.home.manager.source == null);
          message = "`modules.users.${userName_}.home.manager.enable = true` requires `${builtins.toString (./. + "/${builtins.toString user_.home.manager.source}/default.nix")}` to exist.";
        }
      ]) config.modules.users ))

      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : let
        hostUids_ = builtins.attrValues host_.users;
      in lib.optionals host_.enable [
        {
          assertion = builtins.all (uid_ : builtins.elem uid_ enabledUserUids_) hostUids_;
          message = "`modules.hosts.${hostName_}.users` must only contain UIDs enabled in `modules.users` when this host is enabled.";
        }
        {
          assertion = builtins.all (uid_ : builtins.elem uid_ hostUids_) enabledUserUids_;
          message = "Every enabled user in `modules.users` must be declared in `modules.hosts.${hostName_}.users` when this host is enabled.";
        }
      ]) config.modules.hosts))

    ];

    users.users = builtins.listToAttrs (lib.mapAttrsToList (unused_userName_ : user_ : {
      name = builtins.toString user_.uid;
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
    }) (lib.filterAttrs (unused_name_ : user_ : user_.enable && user_.uid != null) config.modules.users));

    home-manager.users = builtins.listToAttrs (lib.mapAttrsToList (unused_userName_ : user_ : {
      name = builtins.toString user_.uid;
      value = {
        imports = lib.optionals (user_.home.manager.source != null) [
          (./. + "/${builtins.toString user_.home.manager.source}")
        ];
        home = {
          uid = lib.mkForce user_.uid;
          username = lib.mkForce user_.username;
          homeDirectory = lib.mkForce (builtins.toString user_.home.directory);
        };
      };
    }) (lib.filterAttrs (unused_name_ : user_ : (user_.enable && user_.uid != null && user_.home.enable && user_.home.manager.enable)) config.modules.users));

  };

}
