{ options, config, pkgs, lib, llib, ... }@args : {

  options = {
    modules.workloads = llib.moduleFunctions.default.mkModuleOptions.default {
      path = ./.;
      commonSchema = (workload_ : {

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

      });
      extraScope = args;
    };
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
