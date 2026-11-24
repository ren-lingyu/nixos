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
  options.features.sops = {
    enable = lib.mkEnableOption "system SOPS integration";
    authorizedUids = lib.mkOption {
      type = lib.types.listOf lib.types.ints.unsigned;
      default = [ ];
      description = "UIDs authorized to read the shared SOPS age key.";
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
      "sops.hm" = {
        rekeyFile = ./sops.hm.age;
        owner = "root";
        group = sopsGroup;
        mode = "0440";
      };
    };
  };
}
