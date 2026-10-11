{
  config,
  llib,
  lib,
  ...
}:
{

  config = {
    assertions = builtins.concatLists (
      lib.mapAttrsToList (
        workloadName_: workload_:
        llib.modules.assertions.existModule {
          enable = workload_.enable;
          value = workload_.existModule;
          optionPath = "modules.workloads.${workloadName_}.existModule";
          osModulePath = ./. + "/${workloadName_}/os/default.nix";
          hmModulePath = ./. + "/${workloadName_}/hm/default.nix";
          enabledMessage = "`modules.workloads.${workloadName_}.enable = true` requires the workload module to declare `existModule.os` and `existModule.hm`.";
        }
      ) config.modules.workloads
    );
  };

}
