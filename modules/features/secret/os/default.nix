{ config, pkgs, lib, ... } : let
  cfg = config.modules.features.secret;
  llib = import ../lib { inherit config; };
  sopsGroup = "sops-decrypt";
in {

  config = lib.mkIf cfg.enable {

    users.groups.${sopsGroup} = {
      name = sopsGroup;
      members = builtins.map (uid_ : config.modules.users."${builtins.toString uid_}".username) cfg.allowUidList;
    };

    environment.systemPackages = with pkgs; [
      age
      sops
      ssh-to-age
      ssh-to-pgp
    ];

    sops = {

      defaultSopsFormat = "yaml";
      defaultSopsFile = ./sops/default.yaml;
      defaultSopsKey = null;
      keepGenerations = 1;
      validateSopsFiles = true;
      environment = {};

      log = [
        "keyImport"
        "secretChanges"
      ];

      age = {
        generateKey = false;
        keyFile = null;
        plugins = [];
        sshKeyPaths = lib.optionals config.services.openssh.enable (
          builtins.map (hostKeys : hostKeys.path) (
            lib.filter (hostKeys : hostKeys.type == "ed25519") config.services.openssh.hostKeys
          )
        );
      };

      secrets."age.keyFile" = {
        key = "age/keyFile";
        path = "/run/secrets/age.keyFile";
        owner = "root";
        group = sopsGroup;
        mode = "0440";
        neededForUsers = false;
      };

    };

  };

}
