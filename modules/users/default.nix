{ config, pkgs, lib, ... } : let

  userProfileList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : ((type_ == "directory") && (builtins.pathExists (./. + "/${name_}/default.nix")))) (builtins.readDir ./.));

in {

  options = {
    modules.users = builtins.listToAttrs (builtins.map (userProfileName_ : {
      name = userProfileName_;
      value = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to enable the ${userProfileName_} user profile.";
        };
        uid = lib.mkOption {
          type = lib.types.unique {
            message = "Conflicting UID assignments for `modules.users.${userProfileName_}.uid`.";
          } (lib.types.nullOr lib.types.ints.unsigned);
          default = null;
          internal = true;
          example = 1000;
          description = "UID assigned to the ${userProfileName_} user profile by the final flake composition.";
        };
        username = lib.mkOption {
          type = lib.types.nonEmptyStr;
          default = userProfileName_;
          example = "jane.doe";
          description = "Login name of the ${userProfileName_} user profile.";
        };
        homeDirectory = lib.mkOption {
          type = lib.types.str;
          default = "/home/${config.modules.users.${userProfileName_}.username}";
          example = "/home/jane.doe";
          description = "Home directory of the ${userProfileName_} user profile. Must be an absolute path.";
        };
      };
    }) userProfileList_);
  };

  config = {

    assertions = let
      enabledUsers_ = lib.filterAttrs (unused_name_ : user_ : user_.enable) config.modules.users;
      enabledUserUids_ = builtins.map (user_ : user_.uid) (builtins.attrValues enabledUsers_);
      enabledAssignedUserUids_ = builtins.filter (uid_ : uid_ != null) enabledUserUids_;
    in builtins.concatLists [

      [
        {
          assertion = let usernames_ = builtins.map (user_ : user_.username) (builtins.attrValues enabledUsers_);
          in (builtins.length usernames_) == builtins.length (lib.unique usernames_);
          message = "Enabled users in `modules.users` must have unique login names.";
        }
        {
          assertion = (builtins.length enabledAssignedUserUids_) == (builtins.length (lib.unique enabledAssignedUserUids_));
          message = "Enabled users in `modules.users` must have unique UIDs.";
        }
      ]

      (builtins.concatLists (lib.mapAttrsToList (userProfileName_ : user_ : [
        {
          assertion = !user_.enable || user_.uid != null;
          message = "`modules.users.${userProfileName_}.enable = true` requires `modules.users.${userProfileName_}.uid` to be assigned by the final flake composition.";
        }
        {
          assertion = user_.uid == null || user_.uid >= 1000;
          message = "`modules.users.${userProfileName_}.uid` must be greater than or equal to 1000 when assigned.";
        }
        {
          assertion = !user_.enable || lib.hasPrefix "/" user_.homeDirectory;
          message = "`modules.users.${userProfileName_}.homeDirectory` must be an absolute path when this user is enabled.";
        }
      ]) config.modules.users ))

      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : let
        hostUids_ = builtins.attrValues host_.users;
      in lib.optionals host_.enable [
        {
          assertion = builtins.all (uid_ : builtins.elem uid_ hostUids_) enabledAssignedUserUids_;
          message = "Every enabled user in `modules.users` must be declared in `modules.hosts.${hostName_}.users` when this host is enabled.";
        }
      ]) config.modules.hosts))

    ];

    users.users = builtins.listToAttrs (lib.mapAttrsToList (unused_userProfileName_ : user_ : {
      name = builtins.toString user_.uid;
      value = {
        isNormalUser = lib.mkForce true;
        uid = lib.mkForce user_.uid;
        name = lib.mkForce user_.username;
        createHome = lib.mkForce true;
        home = lib.mkForce user_.homeDirectory;
      };
    }) (lib.filterAttrs (unused_name_ : user_ : user_.enable && user_.uid != null) config.modules.users));

    home-manager.users = builtins.listToAttrs (lib.mapAttrsToList (userProfileName_ : user_ : {
      name = builtins.toString user_.uid;
      value = {
        imports = [
          (./. + "/${userProfileName_}")
        ];
        home = {
          uid = lib.mkForce user_.uid;
          username = lib.mkForce user_.username;
          homeDirectory = lib.mkForce user_.homeDirectory;
        };
      };
    }) (lib.filterAttrs (unused_name_ : user_ : user_.enable && user_.uid != null) config.modules.users));

  };

}
