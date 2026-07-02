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
        enabledHosts_ = builtins.attrValues (lib.filterAttrs (unused_name_ : host_ : (
          host_.enable
        )) config.modules.hosts);
        activeMonitors_ =
          if (builtins.length enabledHosts_) == 1
          then (builtins.head enabledHosts_).monitors
          else {};
        defaultMonitors_ = builtins.attrValues (lib.filterAttrs (unused_name_ : monitor_ : (
          monitor_.role == "default"
        )) activeMonitors_);
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
        "x11-session"
      ]);
      
    };
    
    assertions = [
      {
        assertion = let
          enabledHosts_ = builtins.attrValues (lib.filterAttrs (unused_name_ : host_ : (
            host_.enable
          )) config.modules.hosts);
        in (!config.modules.features.greeter.enable || (builtins.length enabledHosts_) == 1);
        message = "`modules.features.greeter.enable = true` requires exactly one host in `modules.hosts` to set `enable = true`.";
      }
      {
        assertion = let
          enabledHosts_ = builtins.attrValues (lib.filterAttrs (unused_name_ : host_ : (
            host_.enable
          )) config.modules.hosts);
          activeMonitors_ = (
            if (builtins.length enabledHosts_) == 1
            then (builtins.head enabledHosts_).monitors
            else {}
          );
          defaultMonitors_ = builtins.attrValues (lib.filterAttrs (unused_name_ : monitor_ : (
            monitor_.role == "default"
          )) activeMonitors_);
        in (!config.modules.features.greeter.enable || (builtins.length defaultMonitors_) == 1);
        message = "`modules.features.greeter.enable = true` requires exactly one monitor in the enabled host's `monitors` to set `role = \"default\"`.";
      }
    ];
    
  };
  
}
