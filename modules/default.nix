{ config, pkgs, lib, llib, ... } : {

  imports = [
    ./hosts
    ./users
    ./features
  ];

  options = {
    modules.base = {
      allowUnfreePredicateList = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = [ "github-copilot-cli" ];
        description = "Package names allowed by the global unfree package predicate.";
      };
      createXdgUserDirectories = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Whether to enable and create XDG user directories.";
      };
    };
  };

  config = {

    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        sandbox = true;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    nixpkgs = {
      config.allowUnfreePredicate = pkg : builtins.elem (lib.getName pkg) config.modules.base.allowUnfreePredicateList;
    };

    environment = {
      enableAllTerminfo = lib.mkDefault true;
      systemPackages = with pkgs; [
        git
        vim
        curl
        wget
        gnutar
        gzip
      ];
    };

    networking = {
      nftables.enable = true;
      firewall.enable = true;
    };

    services.userborn = {
      enable = true;
      package = pkgs.userborn;
    };

    age = let
      enabledHost_ = llib.moduleFunctions.hosts.default.getUniqueEnabledHost config.modules.hosts;
    in {
      identityPaths = [
        enabledHost_.identityKeys.ssh.private.path
      ];
      rekey = {
        storageMode = "derivation";
        masterIdentities = [
          {
            identity = "/var/lib/master-key";
            pubkey = "age1zds7ax4umgu9wjwn7yvp4gndv6fl7h2f8ycwa0edx2pgcdqq53ds9jlxt9";
          }
        ];
        hostPubkey = enabledHost_.identityKeys.ssh.public.key;
      };
    };

    systemd.services = {
      "user@" = {
        after = [
          "agenix-install-secrets.service"
        ];
        overrideStrategy = "asDropin";
      };
    };

    programs = {
      extra-container.enable = true;
    };

    home-manager = {

      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";

      sharedModules = [

        ({ config, osConfig, pkgs, lib, ... } : {
          config = {
            programs.fastfetch = {
              enable = lib.mkDefault true;
              package = lib.mkDefault pkgs.fastfetch;
              settings = lib.mkDefault {};
            };
            xdg = {
              enable = true;
              cacheHome = "${config.home.homeDirectory}/.cache";
              configHome = "${config.home.homeDirectory}/.config";
              binHome = "${config.home.homeDirectory}/.local/bin";
              dataHome = "${config.home.homeDirectory}/.local/share";
              stateHome = "${config.home.homeDirectory}/.local/state";
              userDirs = {
                enable = lib.mkForce osConfig.modules.base.createXdgUserDirectories;
                createDirectories = lib.mkForce osConfig.modules.base.createXdgUserDirectories;
                package = pkgs.xdg-user-dirs;
                desktop = "${config.home.homeDirectory}/Desktop";
                download = "${config.home.homeDirectory}/Downloads";
                documents = "${config.home.homeDirectory}/Documents";
                pictures = "${config.home.homeDirectory}/Pictures";
                videos = "${config.home.homeDirectory}/Videos";
                music = "${config.home.homeDirectory}/Music";
                templates = "${config.home.homeDirectory}/Templates";
                projects = "${config.home.homeDirectory}/Projects";
                publicShare = "${config.home.homeDirectory}/Public";
              };
            };
            home = {
              stateVersion = "26.05";
              preferXdgDirectories = config.xdg.enable;
            };
          };
        })

        # Register interfaces for every HM user; their values still merge per user.
        ({ options, config, osConfig, pkgs, lib, llib, ... } : {
          options = {
            moduleInterfaces = (builtins.listToAttrs
              (builtins.map
                (moduleType_ : {
                  name = moduleType_;
                  value = (builtins.listToAttrs
                    (builtins.map
                      (module_ : {
                        name = module_;
                        value = let
                          possibleInterfaceOptionsPath_ = ./. + "/${moduleType_}/${module_}/hm/interface-options.nix";
                        in (lib.optionalAttrs
                          (builtins.pathExists possibleInterfaceOptionsPath_)
                          ((import possibleInterfaceOptionsPath_) module_ {
                            inherit options;
                            inherit config;
                            inherit osConfig;
                            inherit pkgs;
                            inherit lib;
                            inherit llib;
                          })
                        );
                      })
                      (builtins.attrNames
                        (lib.filterAttrs
                          (name_ : type_ : (builtins.all
                            (x_ : x_)
                            [
                              (type_ == "directory")
                              (builtins.pathExists (./. + "/${moduleType_}/${name_}/default.nix"))
                            ]
                          ))
                          (builtins.readDir (./. + "/${moduleType_}"))
                        )
                      )
                    )
                  );
                })
                (builtins.attrNames
                  (lib.filterAttrs
                    (name_ : type_ : (builtins.all
                      (x_ : x_)
                      [
                        (type_ == "directory")
                        (builtins.pathExists (./. + "/${name_}/default.nix"))
                      ]
                    ))
                    (builtins.readDir ./.)
                  )
                )
              )
            );
          };
        })

      ];

    };

  };

}
