{ config, pkgs, lib, ... } : {

  config = lib.mkIf config.modules.hosts.aliyun.enable {
    
    disko.devices.disk = {
      system = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                ];
              };
            };
            root = {
              priority = 2;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };          
          };
        };
      };
    };
    
  };

}
