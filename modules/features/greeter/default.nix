{ options, config, pkgs, lib, ... } : {

  imports = [
    ./os
  ];
  
  config = {
    
    modules.features.greeter = {
      
      existModule = {
        os = true;
        hm = false;
      };
      
      monitor = let
        defaultMonitors_ = builtins.attrValues (lib.filterAttrs (unused_name_ : monitor_ : (
          monitor_.role == "default"
        )) config.modules.hosts.monitors);
      in {
        name =
          if (builtins.length defaultMonitors_) == 1
          then (builtins.head defaultMonitors_).name
          else null;
      };
      
      sessionPackages = builtins.concatLists (builtins.map (
        x_ : lib.optionals (
          (lib.attrByPath [ x_ "session-wrapper" ] null options.modules.features) != null
        ) [ config.modules.features.${x_}.session-wrapper ]
      ) [
        "niri"
      ]);
      
    };
    
    assertions = [
      {
        assertion = let
          defaultMonitors_ = builtins.attrValues (lib.filterAttrs (unused_name_ : monitor_ : (
            monitor_.role == "default"
          )) config.modules.hosts.monitors);
        in (!config.modules.features.greeter.enable || (builtins.length defaultMonitors_) == 1);
        message = "`modules.features.greeter.enable = true` requires exactly one monitor in `modules.hosts.monitors` to set `role = \"default\"`.";
      }
    ];
    
  };
  
}
