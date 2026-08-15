{ config, pkgs, lib, ... } : let

  cfg = config.modules.features.sops;

  sopsGroup = "sops-decrypt";

in {

  config = lib.mkIf cfg.enable {

    users.groups.${sopsGroup} = {
      name = sopsGroup;
      members = cfg.allowUsernameList;
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
