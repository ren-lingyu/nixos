{ options, config, pkgs, lib, llib, ... }@args : let

  cfg = config.modules.hosts;

  mif = llib.moduleFunctions.hosts.default;

  hostList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : (builtins.all
    (x_ : x_)
    [
      (type_ == "directory")
      (builtins.pathExists (./. + "/${name_}/default.nix"))
    ]
  )) (builtins.readDir ./.));

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

in {

  imports = [
    ./boot-manager.nix
    ./identity-keys.nix
    ./wireguard.nix
  ];

  options = {

    modules.hosts = llib.moduleFunctions.default.mkModuleOptions.default {
      path = ./.;
      commonSchema = (host_ : {

        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          example = true;
          description = "Whether to enable this host profile.";
        };

        number = lib.mkOption {
          type = lib.types.ints.positive;
          internal = true;
          readOnly = true;
          example = 1;
          description = "Stable number assigned to this host.";
        };

        users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.unique {
            message = "Each `modules.hosts.${host_}.users.<uid>` can only be defined once.";
          } lib.types.ints.unsigned);
          internal = true;
          default = {};
          example = {
            "1000" = 1000;
          };
          description = "UID-keyed declarations of managed users registered for this host.";
        };

        monitors = lib.mkOption {
          type = lib.types.attrsOf (lib.types.unique {
            message = "Each `modules.hosts.${host_}.monitors.<name>` can only be defined once.";
          } llib.types.monitor);
          internal = true;
          default = {};
          example = {
            "eDP-1" = {
              name = "eDP-1";
              role = "default";
              mode = {
                width = 3072;
                height = 1920;
                refresh = 60.0;
              };
              scale = 1.6;
            };
          };
          description = "Monitor declarations for this host.";
        };

        publicIpAddress = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          internal = true;
          readOnly = true;
          example = "203.0.113.10";
          description = "Public IP address assigned to this host.";
        };

        existModule = lib.mkOption {
          type = llib.types.existModule {
            optionPath = "modules.hosts.${host_}.existModule";
          };
          internal = true;
          default = {};
          description = "Module availability declared by the ${host_} host profile.";
        };

      });
      extraScope = args;
    };

  };

  config = {

    modules.hosts = (lib.genAttrs
      hostList_
      (host_ : let
        possibleMetadataPath_ = ./. + "/${builtins.toString host_}/metadata.nix";
      in (lib.optionalAttrs
        (builtins.pathExists possibleMetadataPath_)
        ((import possibleMetadataPath_)
          host_
          {
            inherit config;
            inherit pkgs;
            inherit lib;
            inherit llib;
          }
        )
      ))
    );

    assertions = (builtins.concatLists [
      [
        {
          assertion = (builtins.tryEval enabledHost_).success;
          message = "Exactly one host in `modules.hosts` must set `enable = true`.";
        }
        {
          assertion = let
            hostNumbers_ = (builtins.map
              (host_ : host_.number)
              (builtins.attrValues cfg)
            );
          in ((builtins.length hostNumbers_) == (builtins.length (lib.unique hostNumbers_)));
          message = "Host numbers must be globally unique.";
        }
      ]
      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : llib.assertions.existModule {
        enable = host_.enable;
        value = host_.existModule;
        optionPath = "modules.hosts.${hostName_}.existModule";
        osModulePath = ./. + "/${hostName_}/os/default.nix";
        hmModulePath = ./. + "/${hostName_}/hm/default.nix";
        enabledMessage = "`modules.hosts.${hostName_}.enable = true` requires the host profile to declare `existModule.os` and `existModule.hm`.";
      }) cfg))
      (builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : (builtins.concatLists [
        (let
          monitors_ = builtins.attrValues host_.monitors;
          defaultMonitors_ = builtins.filter (monitor_ : monitor_.role == "default") monitors_;
          monitorNames_ = builtins.map (monitor_ : monitor_.name) monitors_;
        in [
          {
            assertion = (builtins.length defaultMonitors_) <= 1;
            message = "At most one monitor in `modules.hosts.${hostName_}.monitors` may set `role = \"default\"`.";
          }
          {
            assertion = (builtins.length monitorNames_) == (builtins.length (lib.unique monitorNames_));
            message = "Monitor names in `modules.hosts.${hostName_}.monitors` must be unique.";
          }
          {
            assertion = (builtins.all
              (monitor_ : (monitor_.role != "default") || (monitor_.mode != null))
              monitors_
            );
            message = "`modules.hosts.${hostName_}.monitors.<name>` with `role = \"default\"` must provide a non-null `mode`.";
          }
        ])
        (builtins.concatLists (lib.mapAttrsToList (uidKey_ : uid_ : [
          {
            assertion = builtins.match "^[0-9]+$" uidKey_ != null;
            message = "`modules.hosts.${hostName_}.users.${uidKey_}` must use a numeric UID string as its attribute name, like `modules.hosts.${hostName_}.users.\"1000\"`.";
          }
          {
            assertion = (builtins.all
              (x_ : x_)
              [
                (builtins.match "^[0-9]+$" uidKey_ != null)
                (uidKey_ == builtins.toString uid_)
              ]
            );
            message = "`modules.hosts.${hostName_}.users.${uidKey_}` must use the canonical decimal representation of UID ${builtins.toString uid_}.";
          }
        ]) host_.users))
      ])) cfg))
    ]);

    home-manager.sharedModules = builtins.concatLists (lib.mapAttrsToList (hostName_ : host_ : (lib.optionals
      (builtins.all
        (x_ : x_)
        [
          host_.enable
          (host_.existModule.hm == true)
        ]
      )
      [
        (./. + "/${hostName_}/hm")
      ]
    )) cfg);

  };

}
