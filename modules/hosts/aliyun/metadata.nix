host_ : { config, pkgs, lib, llib, ... } : {

  users = {
    "1000" = 1000;
  };

  monitors = {};

  intranetClaims = {
    ingress = [ "hub" ];
  };

  publicIpAddress = "39.97.244.246";

}
