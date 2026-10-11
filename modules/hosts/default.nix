{
  config,
  lib,
  llib,
  ...
}:
let

  cfg = config.modules.hosts;

  mif = llib.moduleFunctions.hosts.default;

  enabledHost_ = mif.getUniqueEnabledHost config.modules.hosts;

in
{

  imports = [
    ./boot-manager.nix
    ./identity.nix
    ./shared.nix
    ./wireguard.nix
  ];

  config = {

    assertions = (
      builtins.concatLists [
        [
          {
            assertion = (builtins.tryEval enabledHost_).success;
            message = "Exactly one host in `modules.hosts` must set `enable = true`.";
          }
          {
            assertion =
              let
                hostNumbers_ = (builtins.map (host_: host_.number) (builtins.attrValues cfg));
              in
              ((builtins.length hostNumbers_) == (builtins.length (lib.unique hostNumbers_)));
            message = "Host numbers must be globally unique.";
          }
        ]
        (builtins.concatLists (
          lib.mapAttrsToList (
            hostName_: host_:
            llib.assertions.existModule {
              enable = host_.enable;
              value = host_.existModule;
              optionPath = "modules.hosts.${hostName_}.existModule";
              osModulePath = ./. + "/${hostName_}/os/default.nix";
              hmModulePath = ./. + "/${hostName_}/hm/default.nix";
              enabledMessage = "`modules.hosts.${hostName_}.enable = true` requires the host profile to declare `existModule.os` and `existModule.hm`.";
            }
          ) cfg
        ))
        (builtins.concatLists (
          lib.mapAttrsToList (
            hostName_: host_:
            (builtins.concatLists [
              (
                let
                  monitors_ = builtins.attrValues host_.monitors;
                  defaultMonitors_ = builtins.filter (monitor_: monitor_.role == "default") monitors_;
                  monitorNames_ = builtins.map (monitor_: monitor_.name) monitors_;
                in
                [
                  {
                    assertion = (builtins.length defaultMonitors_) <= 1;
                    message = "At most one monitor in `modules.hosts.${hostName_}.monitors` may set `role = \"default\"`.";
                  }
                  {
                    assertion = (builtins.length monitorNames_) == (builtins.length (lib.unique monitorNames_));
                    message = "Monitor names in `modules.hosts.${hostName_}.monitors` must be unique.";
                  }
                  {
                    assertion = (
                      builtins.all (monitor_: (monitor_.role != "default") || (monitor_.mode != null)) monitors_
                    );
                    message = "`modules.hosts.${hostName_}.monitors.<name>` with `role = \"default\"` must provide a non-null `mode`.";
                  }
                ]
              )
              (builtins.concatLists (
                lib.mapAttrsToList (uidKey_: uid_: [
                  {
                    assertion = builtins.match "^[0-9]+$" uidKey_ != null;
                    message = "`modules.hosts.${hostName_}.users.${uidKey_}` must use a numeric UID string as its attribute name, like `modules.hosts.${hostName_}.users.\"1000\"`.";
                  }
                  {
                    assertion = (
                      builtins.all (x_: x_) [
                        (builtins.match "^[0-9]+$" uidKey_ != null)
                        (uidKey_ == builtins.toString uid_)
                      ]
                    );
                    message = "`modules.hosts.${hostName_}.users.${uidKey_}` must use the canonical decimal representation of UID ${builtins.toString uid_}.";
                  }
                ]) host_.users
              ))
            ])
          ) cfg
        ))
      ]
    );

  };

}
