host_ : { config, pkgs, lib, llib, ... } : {

  users = {
    "1000" = 1000;
  };

  monitors = {};

  intranetClaims = {
    ingress = [ "hub" ];
  };

  publicIpAddress = "39.97.244.246";

  publicHostKey.age = "age1t4f2nej3l3nzm2m62hmwdmprymgm3ychhmkp7qnd8lk4du95xvgqlhj06j";

}
