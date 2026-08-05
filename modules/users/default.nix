{ config, pkgs, lib, llib, ... } : let

  userList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : ((type_ == "directory") && (builtins.pathExists (./. + "/${name_}/default.nix")))) (builtins.readDir ./.));

in {

  # User roots declare profile metadata; only their `hm/` implementations are conditional.
  imports = builtins.map (user_ : ./. + "/${user_}") userList_;

  options = {
    modules.users = builtins.listToAttrs (builtins.map (user_ : {
      name = user_;
      value = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to enable the ${user_} user profile.";
        };
        uid = lib.mkOption {
          type = lib.types.unique {
            message = "Conflicting UID assignments for `modules.users.${user_}.uid`.";
          } (lib.types.nullOr lib.types.ints.unsigned);
          default = null;
          internal = true;
          example = 1000;
          description = "UID assigned to the ${user_} user profile by the final flake composition.";
        };
        username = lib.mkOption {
          type = lib.types.nonEmptyStr;
          default = user_;
          example = "jane.doe";
          description = "Login name of the ${user_} user profile.";
        };
        homeDirectory = lib.mkOption {
          type = lib.types.str;
          default = "/home/${config.modules.users.${user_}.username}";
          example = "/home/jane.doe";
          description = "Home directory of the ${user_} user profile. Must be an absolute path.";
        };
        existModule = lib.mkOption {
          type = llib.types.existModule {
            optionPath = "modules.users.${user_}.existModule";
          };
          internal = true;
          default = {};
          description = "Module availability declared by the ${user_} user profile.";
        };
      };
    }) userList_);
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

      (builtins.concatLists (lib.mapAttrsToList (userName_ : user_ : builtins.concatLists [
        [
          {
            assertion = !user_.enable || user_.uid != null;
            message = "`modules.users.${userName_}.enable = true` requires `modules.users.${userName_}.uid` to be assigned by the final flake composition.";
          }
          {
            assertion = user_.uid == null || user_.uid >= 1000;
            message = "`modules.users.${userName_}.uid` must be greater than or equal to 1000 when assigned.";
          }
          {
            assertion = !user_.enable || lib.hasPrefix "/" user_.homeDirectory;
            message = "`modules.users.${userName_}.homeDirectory` must be an absolute path when this user is enabled.";
          }
        ]
        (llib.assertions.existModule {
          enable = user_.enable;
          value = user_.existModule;
          optionPath = "modules.users.${userName_}.existModule";
          osModulePath = ./. + "/${userName_}/os/default.nix";
          hmModulePath = ./. + "/${userName_}/hm/default.nix";
          enabledMessage = "`modules.users.${userName_}.enable = true` requires the user profile to declare `existModule.os` and `existModule.hm`.";
        })
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

    users.users = builtins.listToAttrs (lib.mapAttrsToList (unused_userName_ : user_ : {
      name = builtins.toString user_.uid;
      value = {
        isNormalUser = lib.mkForce true;
        uid = lib.mkForce user_.uid;
        name = lib.mkForce user_.username;
        createHome = lib.mkForce true;
        home = lib.mkForce user_.homeDirectory;
      };
    }) (lib.filterAttrs (unused_name_ : user_ : user_.enable && user_.uid != null) config.modules.users));

    home-manager.users = builtins.listToAttrs (lib.mapAttrsToList (userName_ : user_ : {
      name = builtins.toString user_.uid;
      value = {
        imports = lib.optionals (user_.existModule.hm == true) [
          (./. + "/${userName_}/hm")
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
