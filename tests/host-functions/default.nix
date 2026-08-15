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
   assert hostFunctions_.getUniqueEnabledHost noEnabledHosts_ == {};
   assert hostFunctions_.getUniqueEnabledHost multipleEnabledHosts_ == {};
pkgs.runCommand "nixos-host-functions" {} ''
  touch $out
''
