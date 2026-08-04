{ config, lib, pkgs, ... } : {

  config = {

    modules.users.lingyu-minimal = {
      existModule = {
        os = false;
        hm = false;
      };
    };

  };

}
