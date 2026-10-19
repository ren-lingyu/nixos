{ pkgs, llib }:
let
  lib = pkgs.lib;

  assertionOptions_ = {
    options = {
      assertions = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              assertion = lib.mkOption { type = lib.types.bool; };
              message = lib.mkOption { type = lib.types.str; };
            };
          }
        );
        default = [ ];
      };
      modules = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = { };
      };
    };
  };

  assertionOnlyModule_ =
    modulePath_: args_:
    let
      loadModule_ =
        module_:
        if lib.isFunction module_ then
          module_ args_
        else if lib.isAttrs module_ then
          module_
        else
          loadModule_ (import module_);

      stripModule_ =
        module_:
        let
          attrs_ = loadModule_ module_;
        in
        {
          imports = builtins.map stripModule_ (attrs_.imports or [ ]);
          options = attrs_.options or { };
          config.assertions = (attrs_.config or { }).assertions or [ ];
        };
    in
    stripModule_ modulePath_;

  hostFixture_ =
    builtins.mapAttrs
      (
        unused_name: metadata:
        lib.mergeAttrsList [
          { enable = false; }
          metadata
        ]
      )
      {
        thinkbook = import ../../modules/hosts/thinkbook/_metadata.nix;
        matebook = import ../../modules/hosts/matebook/_metadata.nix;
        aliyun = import ../../modules/hosts/aliyun/_metadata.nix;
        wsl = import ../../modules/hosts/wsl/_metadata.nix;
      };

  # Simulated NixOS inputs; production availability is derived by the Registry.
  userFixture_ = {
    lingyu = {
      enable = false;
      uid = null;
      username = "lingyu";
      homeDirectory = "/home/lingyu";
      existModule = {
        os = false;
        hm = true;
      };
    };
  };

  featureFixture_ = {
    editor = {
      enable = false;
      allowUidList = [ ];
      existModule = {
        os = false;
        hm = true;
      };
    };
  };

  testModules_ = {
    hosts = hostFixture_;
    users = userFixture_;
    features = featureFixture_;
  };

  evalHostUserAssertions_ =
    modules_:
    (lib.evalModules {
      specialArgs = { inherit pkgs llib; };
      modules = [
        assertionOptions_
        (assertionOnlyModule_ ../../modules/hosts)
        (assertionOnlyModule_ ../../modules/users)
        { config.modules = lib.recursiveUpdate testModules_ modules_; }
      ];
    }).config.assertions;

  evalFeatureAssertions_ =
    modules_:
    (lib.evalModules {
      specialArgs = { inherit pkgs llib; };
      modules = [
        assertionOptions_
        (assertionOnlyModule_ ../../modules/features)
        { config.modules = lib.recursiveUpdate testModules_ modules_; }
      ];
    }).config.assertions;

  assertionByMessage_ =
    message_: assertions_:
    lib.findFirst (
      assertion_: assertion_.message == message_
    ) (throw "Expected assertion `${message_}` was not generated.") assertions_;

  uniqueEnabledHostAssertionMessage_ = "Exactly one host in `modules.hosts` must set `enable = true`.";

  noEnabledHostAssertion_ = assertionByMessage_ uniqueEnabledHostAssertionMessage_ (
    evalHostUserAssertions_ { }
  );

  oneEnabledHostAssertion_ =
    assertionByMessage_ uniqueEnabledHostAssertionMessage_
      (evalHostUserAssertions_ {
        hosts.thinkbook.enable = true;
      });

  multipleEnabledHostAssertion_ =
    assertionByMessage_ uniqueEnabledHostAssertionMessage_
      (evalHostUserAssertions_ {
        hosts = {
          aliyun.enable = true;
          thinkbook.enable = true;
        };
      });

  missingUidAssertion_ =
    assertionByMessage_
      "`modules.users.lingyu.enable = true` requires `modules.users.lingyu.uid` to be assigned by the final flake composition."
      (evalHostUserAssertions_ {
        hosts.thinkbook.enable = true;
        users.lingyu.enable = true;
      });

  unregisteredUidAssertion_ =
    assertionByMessage_
      "Every enabled user in `modules.users` must be declared in `modules.hosts.thinkbook.users` when this host is enabled."
      (evalHostUserAssertions_ {
        hosts.thinkbook.enable = true;
        users.lingyu = {
          enable = true;
          uid = 1001;
        };
      });

  unknownFeatureUidAssertion_ =
    assertionByMessage_
      "`modules.features.editor.allowUidList` must only contain UIDs assigned to enabled users in `modules.users`."
      (evalFeatureAssertions_ {
        users.lingyu = {
          enable = true;
          uid = 1000;
        };
        features.editor = {
          enable = true;
          allowUidList = [ 1001 ];
        };
      });

in
assert !noEnabledHostAssertion_.assertion;
assert oneEnabledHostAssertion_.assertion;
assert !multipleEnabledHostAssertion_.assertion;
assert !missingUidAssertion_.assertion;
assert !unregisteredUidAssertion_.assertion;
assert !unknownFeatureUidAssertion_.assertion;
pkgs.runCommand "nixos-module-composition" { } ''
  touch $out
''
