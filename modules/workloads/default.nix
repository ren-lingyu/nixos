{ options, config, pkgs, lib, llib, ... } : let

  workloadList_ = builtins.attrNames (lib.filterAttrs (name_ : type_ : (builtins.all
    (x_ : x_)
    [
      (type_ == "directory")
      (builtins.pathExists (./. + "/${name_}/default.nix"))
    ]
  )) (builtins.readDir ./.));

in {

  options = {
    modules.workloads = builtins.listToAttrs (builtins.map (workload_ : {
      name = workload_;
      value = let
        possibleExtraOptionsPath_ = ./. + "/${builtins.toString workload_}/extra-options.nix";
      in (lib.mergeAttrsList [
        {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = "Whether to enable the ${workload_} workload.";
          };
          existModule = lib.mkOption {
            type = llib.types.existModule {
              optionPath = "modules.workloads.${workload_}.existModule";
            };
            internal = true;
            default = {};
            description = "Module availability declared by the ${workload_} workload.";
          };
        }
        (lib.optionalAttrs (builtins.pathExists possibleExtraOptionsPath_) (
          (import possibleExtraOptionsPath_) workload_ {
            inherit options;
            inherit config;
            inherit pkgs;
            inherit lib;
            inherit llib;
          }
        ))
      ]);
    }) workloadList_);
  };

  config = {
    assertions = builtins.concatLists (lib.mapAttrsToList (workloadName_ : workload_ : llib.assertions.existModule {
      enable = workload_.enable;
      value = workload_.existModule;
      optionPath = "modules.workloads.${workloadName_}.existModule";
      osModulePath = ./. + "/${workloadName_}/os/default.nix";
      hmModulePath = ./. + "/${workloadName_}/hm/default.nix";
      enabledMessage = "`modules.workloads.${workloadName_}.enable = true` requires the workload module to declare `existModule.os` and `existModule.hm`.";
    }) config.modules.workloads);
  };

}
