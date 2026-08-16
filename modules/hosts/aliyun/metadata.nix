host_ : { config, pkgs, lib, llib, ... } : {

  users = {
    "1000" = 1000;
  };

  monitors = {};

  intranetClaims = {
    ingress = [ "hub" ];
  };

  publicIpAddress = "39.97.244.246";

  identityKeys = {
    ssh = {
      public = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILI3dfdpwVhrRohWXLm694Y21dS2JeIpWN8CJcwURtl5";
        ageRecipient = "age1t4f2nej3l3nzm2m62hmwdmprymgm3ychhmkp7qnd8lk4du95xvgqlhj06j";
        path = "/etc/ssh/ssh_host_ed25519_key.pub";
      };
      private = {
        key = ./ssh.private.age;
        path = "/etc/ssh/ssh_host_ed25519_key";
      };
    };
  };

}
