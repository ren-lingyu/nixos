{ config, lib, pkgs, ... } : let

  cfg = config.modules.features.sops;

  getUsernameByUid_ = uid_ : let
    enabledUsersByUid_ = builtins.listToAttrs (builtins.map (user_ : {
      name = builtins.toString user_.uid;
      value = user_.username;
    }) (builtins.attrValues (lib.filterAttrs (unused_userName_ : user_ : user_.enable && user_.uid != null) config.modules.users)));
  in (
    if builtins.hasAttr (builtins.toString uid_) enabledUsersByUid_
    then enabledUsersByUid_."${builtins.toString uid_}"
    else builtins.throw "No enabled user in `modules.users` is assigned UID ${builtins.toString uid_}."
  );

in {

  imports = [
    ./os
  ];

  config = {
    modules.features.sops = {
      existModule = {
        os = true;
        hm = true;
      };
      allowUsernameList = lib.optionals cfg.enable (builtins.map getUsernameByUid_ cfg.allowUidList);
    };
  };

}
