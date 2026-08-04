{ pkgs, llib } : let

  lib = pkgs.lib;

  assertionOption_ = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        assertion = lib.mkOption {
          type = lib.types.bool;
        };
        message = lib.mkOption {
          type = lib.types.str;
        };
      };
    });
    default = [];
  };

  integrationOptions_ = {
    options = {
      assertions = assertionOption_;
      home-manager = {
        users = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
        };
        sharedModules = lib.mkOption {
          type = lib.types.listOf lib.types.anything;
          default = [];
        };
      };
      users.users = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };
    };
  };

  evalHostUserAssertions_ = config_ : (lib.evalModules {
    specialArgs = {
      inherit pkgs llib;
    };
    modules = [
      integrationOptions_
      ../../modules/hosts
      ../../modules/users
      { config = config_; }
    ];
  }).config.assertions;

  evalFeatureAssertions_ = config_ : (lib.evalModules {
    specialArgs = {
      inherit pkgs llib;
    };
    modules = [
      integrationOptions_
      {
        options.modules.users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
              uid = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.unsigned;
                default = null;
              };
            };
          });
          default = {};
        };
      }
      ../../modules/features
      { config = config_; }
    ];
  }).config.assertions;

  assertionByMessage_ = message_ : assertions_ : lib.findFirst
    (assertion_ : assertion_.message == message_)
    (throw "Expected assertion `${message_}` was not generated.")
    assertions_;

  missingUidAssertion_ = assertionByMessage_
    "`modules.users.lingyu.enable = true` requires `modules.users.lingyu.uid` to be assigned by the final flake composition."
    (evalHostUserAssertions_ {
      modules.users.lingyu.enable = true;
    });

  unregisteredUidAssertion_ = assertionByMessage_
    "Every enabled user in `modules.users` must be declared in `modules.hosts.thinkbook.users` when this host is enabled."
    (evalHostUserAssertions_ {
      modules = {
        hosts.thinkbook.enable = true;
        users.lingyu = {
          enable = true;
          uid = 1000;
        };
      };
    });

  unknownFeatureUidAssertion_ = assertionByMessage_
    "`modules.features.editor.allowUidList` must only contain UIDs assigned to enabled users in `modules.users`."
    (evalFeatureAssertions_ {
      modules = {
        users.lingyu = {
          enable = true;
          uid = 1000;
        };
        features.editor = {
          enable = true;
          allowUidList = [ 1001 ];
          existModule = {
            os = false;
            hm = true;
          };
        };
      };
    });

in assert !missingUidAssertion_.assertion;
   assert !unregisteredUidAssertion_.assertion;
   assert !unknownFeatureUidAssertion_.assertion;
pkgs.runCommand "nixos-module-composition" {} ''
  touch $out
''
