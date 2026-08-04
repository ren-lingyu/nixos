{ options, config, pkgs, lib, ... } : let

  cfg = config.modules.features.greeter;

in {

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
        providerName_ : let
          hasSessionWrapperOption_ = (
            (lib.attrByPath [ providerName_ "session-wrapper" ] null options.modules.features) != null
          );
          sessionWrapper_ = config.modules.features.${providerName_}.session-wrapper;
        in lib.optionals (hasSessionWrapperOption_ && sessionWrapper_ != null) [
          sessionWrapper_
        ]
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
        in (!cfg.enable || (builtins.length enabledHosts_) == 1);
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
        in (!cfg.enable || (builtins.length defaultMonitors_) == 1);
        message = "`modules.features.greeter.enable = true` requires exactly one monitor in the enabled host's `monitors` to set `role = \"default\"`.";
      }
      {
        assertion = !cfg.enable || cfg.sessionPackages != [];
        message = "`modules.features.greeter.enable = true` requires at least one session provider.";
      }
    ];

  };

}
