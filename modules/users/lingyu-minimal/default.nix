{ config, pkgs, lib, ... } : {

  config = {

    modules.users.lingyu-minimal = {
      existModule = {
        os = false;
        hm = false;
      };
    };

  };

}
