{ config, lib, pkgs, ... } : {

  config = {

    modules.users.lingyu = {
      existModule = {
        os = false;
        hm = true;
      };
    };

  };

}
