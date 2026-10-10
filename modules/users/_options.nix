{
  lib,
  config,
  path,
  ...
}:
let
  user_ = lib.last path;
in
{
  uid = lib.mkOption {
    type = lib.types.unique {
      message = "Conflicting UID assignments for `modules.users.${user_}.uid`.";
    } (lib.types.nullOr lib.types.ints.unsigned);
    default = null;
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
}
