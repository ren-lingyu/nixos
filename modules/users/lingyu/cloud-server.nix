{ config, pkgs, lib, ... } : {

  programs.ssh.settings = lib.mkIf config.programs.ssh.enable {
    "aliyun" = {
      hostname = "39.97.244.246";
      user = "lingyu";
      port = 22;
      identityFile = "~/.ssh/id_ed25519";
      identitiesOnly = true;
    };
    "root.aliyun" = {
      hostname = "39.97.244.246";
      user = "root";
      port = 22;
      identityFile = "~/.ssh/id_ed25519";
      identitiesOnly = true;
    };
  };

}
