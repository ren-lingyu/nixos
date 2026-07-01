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
        defaultMonitors_ = builtins.head (
          builtins.attrValues (lib.filterAttrs (unused_name_ : monitor_ : (
            monitor_.role == "default"
          )) config.modules.hosts.monitors)
        );
      in {
        name = defaultMonitors_.name;
      };
      
      sessionPackages = builtins.concatLists (builtins.map (
        x_ : lib.optionals (
          (lib.attrByPath [ x_ "session-wrapper" ] null options.modules.features) != null
        ) [ config.modules.features.${x_}.session-wrapper ]
      ) [
        "niri"
      ]);
      
    };
    
  };
  
}
