{ config, pkgs, lib, ... } : let

  cfg = config.modules.hosts.thinkbook;

  vm = rec {

    media = {
      directory = "/var/lib/libvirt/boot";
      windows.iso = "${media.directory}/Windows_x64.iso";
      virtio.iso = builtins.derivation {
        name = "virtio-win.iso";
        system = pkgs.stdenv.hostPlatform.system;
        builder = lib.getExe' pkgs.cdrtools "mkisofs";
        args = [
          "-J"
          "-V"
          "VIRTIO-WIN"
          "-o"
          (builtins.placeholder "out")
          "${pkgs.virtio-win}"
        ];
      };
    };

    domains = {
      windows = {
        name = "windows";
        devices = {
          hostdevs.gpu = {
            physicalFunction.address = "0000:00:02.0";
            source.address = {
              domain = "0x0000";
              bus = "0x00";
              slot = "0x02";
              function = "0x1";
            };
          };
          disks = {
            system.source = {
              pool = pools.windows.name;
              volume = pools.windows.volumes.system.name;
            };
            windows.source.file = media.windows.iso;
            virtio.source.file = media.virtio.iso;
          };
          interfaces.default = {
            mac.address = networks.default.hosts.windows.mac;
            source.network = networks.default.name;
          };
        };
      };
    };

    networks = {
      default = {
        name = "default";
        bridge.name = "virbr0";
        hosts.windows = {
          name = domains.windows.name;
          mac = "52:54:00:e6:35:a0";
          ip = "192.168.122.10";
        };
      };
    };

    pools = {
      windows = {
        name = "windows";
        target.path = "/var/lib/libvirt/images/windows";
        volumes.system.name = "system.qcow2";
      };
    };

  };

in {

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      freerdp
      virt-viewer
    ];

    services.udev.extraRules = (builtins.concatStringsSep
      ",${builtins.fromJSON "\"\\u0020\""}"
      [
        "ACTION==\"bind\""
        "SUBSYSTEM==\"pci\""
        "KERNEL==\"${vm.domains.windows.devices.hostdevs.gpu.physicalFunction.address}\""
        "DRIVER==\"xe\""
        "ATTR{sriov_numvfs}==\"0\""
        "ATTR{sriov_numvfs}=\"1\""
      ]
    );

    systemd.tmpfiles.rules = [
      "d ${vm.media.directory} 0755 root root - -"
      "d ${vm.pools.windows.target.path} 0755 root root - -"
      "z ${vm.media.windows.iso} 0644 root root - -"
    ];

    networking.firewall.interfaces.${vm.networks.default.bridge.name} = {
      allowedTCPPorts = [
        53
        445
      ];
      allowedUDPPorts = [
        53
        67
      ];
    };

    services.samba = {
      enable = config.fileSystems.shared.enable;
      openFirewall = false;
      nmbd.enable = false;
      winbindd.enable = false;
      settings = {
        global = {
          "server role" = "standalone server";
          "interfaces" = [
            "lo"
            vm.networks.default.bridge.name
          ];
          "bind interfaces only" = "yes";
          "hosts allow" = [
            "127.0.0.1"
            vm.networks.default.hosts.windows.ip
          ];
          "hosts deny" = [
            "0.0.0.0/0"
          ];
          "smb ports" = 445;
        };
        Shared = {
          path = config.fileSystems.shared.mountPoint;
          browseable = "no";
          "read only" = "no";
          "valid users" = [
            "vm-shared"
          ];
          "force user" = "root";
        };
      };
    };

    users = {
      groups.vm-shared = {};
      users.vm-shared = {
        isSystemUser = true;
        group = "vm-shared";
      };
    };

    virtualisation = {

      libvirtd = {
        enable = true;
        package = pkgs.libvirt;
      };

      libvirt = {
        enable = true;
        package = config.virtualisation.libvirtd.package;
        verbose = true;
        swtpm.enable = true;
        connections."qemu:///system" = {

          domains = [
            {
              definition = let
                hasInitialized_ = true;
                mkMediaDiskBlock_ = x_ : y_ : builtins.concatStringsSep "\n${builtins.fromJSON ''"\u0020\u0020\u0020\u0020"''}" [
                  "<disk type='file' device='cdrom'>"
                  "    <driver name='qemu' type='raw'/>"
                  "    <source file='${x_}'/>"
                  "    <target dev='${y_}' bus='sata'/>"
                  "    <readonly/>"
                  "</disk>"
                ];
              in (pkgs.replaceVars
                ./domain/windows.xml
                (lib.mergeAttrsList
                  [
                    {
                      domain_name = vm.domains.windows.name;
                      domain_devices_disks_system_source_pool = vm.domains.windows.devices.disks.system.source.pool;
                      domain_devices_disks_system_source_volume = vm.domains.windows.devices.disks.system.source.volume;
                      domain_devices_interfaces_default_mac_address = vm.domains.windows.devices.interfaces.default.mac.address;
                      domain_devices_interfaces_default_source_network = vm.domains.windows.devices.interfaces.default.source.network;
                      domain_devices_hostdevs_gpu_source_address_domain = vm.domains.windows.devices.hostdevs.gpu.source.address.domain;
                      domain_devices_hostdevs_gpu_source_address_bus = vm.domains.windows.devices.hostdevs.gpu.source.address.bus;
                      domain_devices_hostdevs_gpu_source_address_slot = vm.domains.windows.devices.hostdevs.gpu.source.address.slot;
                      domain_devices_hostdevs_gpu_source_address_function = vm.domains.windows.devices.hostdevs.gpu.source.address.function;
                      domain_os_boot_cdrom = "";
                      domain_devices_disks_windows = "";
                      domain_devices_disks_virtio = "";
                    }
                    (lib.optionalAttrs
                      (hasInitialized_ == false)
                      {
                        domain_os_boot_cdrom = "<boot dev='cdrom'/>";
                        domain_devices_disks_windows = (mkMediaDiskBlock_
                          vm.domains.windows.devices.disks.windows.source.file
                          "sda"
                        );
                        domain_devices_disks_virtio = (mkMediaDiskBlock_
                          vm.domains.windows.devices.disks.virtio.source.file
                          "sdb"
                        );
                      }
                    )
                  ]
                )
              );
              restart = false;
              active = null;
            }
          ];

          networks = [
            {
              definition = (pkgs.replaceVars
                ./networks/default.xml
                {
                  network_name = vm.networks.default.name;
                  network_bridge_name = vm.networks.default.bridge.name;
                  network_hosts_windows_name = vm.networks.default.hosts.windows.name;
                  network_hosts_windows_mac = vm.networks.default.hosts.windows.mac;
                  network_hosts_windows_ip = vm.networks.default.hosts.windows.ip;
                }
              );
              restart = false;
              active = true;
            }
          ];

          pools = [
            {
              definition = (pkgs.replaceVars
                ./pools/windows/pool.xml
                {
                  pool_name = vm.pools.windows.name;
                  pool_target_path = vm.pools.windows.target.path;
                }
              );
              restart = false;
              active = true;
              volumes = [
                {
                  definition = (pkgs.replaceVars
                    ./pools/windows/volume/system.xml
                    {
                      volume_name = vm.pools.windows.volumes.system.name;
                    }
                  );
                  present = true;
                }
              ];
            }
          ];

        };
      };

    };

  };

}
