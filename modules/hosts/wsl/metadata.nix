host_ : { config, pkgs, lib, llib, ... } : {

  users = {
    "1000" = 1000;
  };

  monitors = {};

  intranetClaims = {};

  publicHostKey = {
    ssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICbbqlpVdSNnKrAKqZE76UVGXY+9AY3/P4nC9hToB0V3";
    age = "age1x6nxamdaqd9428nth4f4p2ltnm4sehwp9msln0l45h4dpkv2pp8shm7x8l";
  };

}
