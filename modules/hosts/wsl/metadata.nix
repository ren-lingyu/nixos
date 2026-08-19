host_ : { config, pkgs, lib, llib, ... } : {

  number = 1;

  users = {
    "1000" = 1000;
  };

  monitors = {};

  publicIpAddress = null;

  wireguard = {
    publicKey = "E8VcIYOgkRsmqZtrWSknRKO0xUGeAYlFDt4XMTHGK3M=";
    privateKey = ./wireguard.private.age;
    listenPort = null;
    endpoint = null;
  };

  identityKeys = {
    ssh = {
      public = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICbbqlpVdSNnKrAKqZE76UVGXY+9AY3/P4nC9hToB0V3";
        ageRecipient = "age1x6nxamdaqd9428nth4f4p2ltnm4sehwp9msln0l45h4dpkv2pp8shm7x8l";
        path = "/etc/ssh/ssh_host_ed25519_key.pub";
      };
      private = {
        key = ./ssh.private.age;
        path = "/etc/ssh/ssh_host_ed25519_key";
      };
    };
  };

}
