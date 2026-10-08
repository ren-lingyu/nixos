{ config, pkgs, lib, ... } : {

  config = {

    modules.users.lingyu = {
      existModule = {
        os = false;
        hm = true;
      };
    };

  };

}
