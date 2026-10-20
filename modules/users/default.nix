{ config, lib, ... }: {

  config = {

    users.users = builtins.listToAttrs (
      lib.mapAttrsToList
        (unused_userName_: user_: {
          name = builtins.toString user_.uid;
          value = {
            isNormalUser = lib.mkForce true;
            uid = lib.mkForce user_.uid;
            name = lib.mkForce user_.username;
            createHome = lib.mkForce true;
            home = lib.mkForce user_.homeDirectory;
          };
        })
        (
          lib.filterAttrs (
            unused_name_: user_:
            (builtins.all (x_: x_) [
              user_.enable
              (user_.uid != null)
            ])
          ) config.modules.users
        )
    );

    home-manager.users = builtins.listToAttrs (
      lib.mapAttrsToList
        (unused_userName_: user_: {
          name = builtins.toString user_.uid;
          value = {
            home = {
              uid = lib.mkForce user_.uid;
              username = lib.mkForce user_.username;
              homeDirectory = lib.mkForce user_.homeDirectory;
            };
          };
        })
        (
          lib.filterAttrs (
            unused_name_: user_:
            (builtins.all (x_: x_) [
              user_.enable
              (user_.uid != null)
            ])
          ) config.modules.users
        )
    );

  };

}
