{ pkgs, llib } : let

  hostFunctions_ = llib.moduleFunctions.hosts.default;

  hosts_ = {
    disabled = {
      enable = false;
      value = "disabled";
    };
    enabled = {
      enable = true;
      value = "enabled";
    };
  };

  noEnabledHosts_ = {
    disabled.enable = false;
  };

  multipleEnabledHosts_ = {
    first.enable = true;
    second.enable = true;
  };

in assert (hostFunctions_.getUniqueEnabledHost hosts_).value == "enabled";
   assert (builtins.tryEval (hostFunctions_.getUniqueEnabledHost noEnabledHosts_)).success == false;
   assert (builtins.tryEval (hostFunctions_.getUniqueEnabledHost multipleEnabledHosts_)).success == false;
pkgs.runCommand "nixos-host-functions" {} ''
  touch $out
''
