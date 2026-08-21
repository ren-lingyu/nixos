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

  assertionOptions_ = {
    options.assertions = assertionOption_;
  };

  assertionOnlyModule_ = modulePath_ : args_ : let

    loadModule_ = module_ :
      if lib.isFunction module_ then
        module_ args_
      else if lib.isAttrs module_ then
        module_
      else
        loadModule_ (import module_);

    stripModule_ = module_ : let
      attrs_ = loadModule_ module_;
    in {
      imports =
        builtins.map stripModule_
          (attrs_.imports or []);
      options = attrs_.options or {};
      config.assertions =
        (attrs_.config or {}).assertions or [];
    };

  in stripModule_ modulePath_;

  testHostMetadata_ = { options, ... } : {
    config.modules.hosts = builtins.mapAttrs
      (unused_name_ : unused_hostOptions_ : {
        wireguard = null;
      })
      options.modules.hosts;
  };

  evalHostUserAssertions_ = config_ : (lib.evalModules {
    specialArgs = {
      inherit pkgs llib;
    };
    modules = [
      assertionOptions_
      (assertionOnlyModule_ ../../modules/hosts)
      (assertionOnlyModule_ ../../modules/users)
      testHostMetadata_
      { config = config_; }
    ];
  }).config.assertions;

  evalFeatureAssertions_ = config_ : (lib.evalModules {
    specialArgs = {
      inherit pkgs llib;
    };
    modules = [
      assertionOptions_
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
      (assertionOnlyModule_ ../../modules/features)
      { config = config_; }
    ];
  }).config.assertions;

  assertionByMessage_ = message_ : assertions_ : lib.findFirst
    (assertion_ : assertion_.message == message_)
    (throw "Expected assertion `${message_}` was not generated.")
    assertions_;

  hostExistModule_ = {
    os = true;
    hm = false;
  };

  uniqueEnabledHostAssertionMessage_ = "Exactly one host in `modules.hosts` must set `enable = true`.";

  noEnabledHostAssertion_ = assertionByMessage_
    uniqueEnabledHostAssertionMessage_
    (evalHostUserAssertions_ {});

  oneEnabledHostAssertion_ = assertionByMessage_
    uniqueEnabledHostAssertionMessage_
    (evalHostUserAssertions_ {
      modules.hosts.thinkbook = {
        enable = true;
        existModule = hostExistModule_;
      };
    });

  multipleEnabledHostAssertion_ = assertionByMessage_
    uniqueEnabledHostAssertionMessage_
    (evalHostUserAssertions_ {
      modules.hosts = {
        aliyun = {
          enable = true;
          existModule = hostExistModule_;
        };
        thinkbook = {
          enable = true;
          existModule = hostExistModule_;
        };
      };
    });

  missingUidAssertion_ = assertionByMessage_
    "`modules.users.lingyu.enable = true` requires `modules.users.lingyu.uid` to be assigned by the final flake composition."
    (evalHostUserAssertions_ {
      modules = {
        hosts.thinkbook = {
          enable = true;
          existModule = hostExistModule_;
        };
        users.lingyu.enable = true;
      };
    });

  unregisteredUidAssertion_ = assertionByMessage_
    "Every enabled user in `modules.users` must be declared in `modules.hosts.thinkbook.users` when this host is enabled."
    (evalHostUserAssertions_ {
      modules = {
        hosts.thinkbook = {
          enable = true;
          existModule = hostExistModule_;
          users = lib.mkForce {};
        };
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

in assert !noEnabledHostAssertion_.assertion;
   assert oneEnabledHostAssertion_.assertion;
   assert !multipleEnabledHostAssertion_.assertion;
   assert !missingUidAssertion_.assertion;
   assert !unregisteredUidAssertion_.assertion;
   assert !unknownFeatureUidAssertion_.assertion;
pkgs.runCommand "nixos-module-composition" {} ''
  touch $out
''
