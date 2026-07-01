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
