{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.features.sops;

  sopsGroup = "sops-decrypt";
in
{
  options = {
    features.sops = {
      enable = lib.mkEnableOption "system SOPS integration";
      authorizedUids = lib.mkOption {
        type = lib.types.listOf lib.types.ints.unsigned;
        readOnly = true;
        description = "UIDs authorized to read the shared SOPS age key.";
      };
      ageKeys.hm = {
        name = lib.mkOption {
          type = lib.types.nonEmptyStr;
          readOnly = true;
          default = "sops.hm";
          description = "System age secret containing the shared Home Manager SOPS age key.";
        };
        path = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = config.age.secrets.${cfg.ageKeys.hm.name}.path;
          description = "Runtime path of the shared Home Manager SOPS age key.";
        };
      };
    };
  };

  config = lib.mkIf config.features.sops.enable {
    users.groups.${sopsGroup} = {
      name = sopsGroup;
      members = builtins.map (
        uid:
        let
          accounts = lib.filter (account: account.uid == uid) (lib.attrValues config.users.users);
        in
        if builtins.length accounts == 1 then
          (builtins.head accounts).name
        else
          throw "SOPS authorized UID ${toString uid} must match exactly one system account."
      ) cfg.authorizedUids;
    };

    environment.systemPackages = with pkgs; [
      age
      sops
      ssh-to-age
      ssh-to-pgp
    ];

    age.secrets = {
      ${cfg.ageKeys.hm.name} = {
        rekeyFile = ./sops.hm.age;
        owner = "root";
        group = sopsGroup;
        mode = "0440";
      };
    };
  };
}
