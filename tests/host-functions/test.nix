{ runCommand, hosts }:
let

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

in
assert (hosts.getUniqueEnabledHost hosts_).value == "enabled";
assert (builtins.tryEval (hosts.getUniqueEnabledHost noEnabledHosts_)).success == false;
assert (builtins.tryEval (hosts.getUniqueEnabledHost multipleEnabledHosts_)).success == false;
runCommand "nixos-host-functions" { } ''
  touch $out
''
