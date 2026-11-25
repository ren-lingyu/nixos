{
  lib,
  runCommand,
  secrets,
  sops,
}:
let

  assertEqual =
    name_: expected_: actual_:
    if actual_ == expected_ then true else throw "Test `${name_}` failed: values differ.";

  sopsFunctions_ = secrets {
    config = {
      home.uid = 1000;
      sops = {
        defaultSopsFormat = "yaml";
        defaultSopsFile = ./test.nix;
      };
    };
  };

  secrets_ = sopsFunctions_.mkSopsSecrets [
    {
      template = "system";
      structure.database = [ "password" ];
      overlay.mode = "0440";
    }
    "ignored"
    {
      template = "user";
      structure.cloud.token = [ ];
    }
  ];

  tests_ = [
    (assertEqual "structure expansion"
      [
        [ "empty" ]
        [
          "list"
          "first"
        ]
        [
          "list"
          "second"
        ]
        [
          "nested"
          "leaf"
        ]
      ]
      (
        sopsFunctions_.fromStructure {
          empty = [ ];
          ignored = "value";
          list = [
            "first"
            "second"
          ];
          nested.leaf = [ ];
        }
      )
    )
    (assertEqual "system template" {
      name = "database.password";
      key = "database/password";
      mode = "0440";
      path = "/run/secrets/database.password";
      format = "yaml";
      sopsFile = ./test.nix;
      neededForUsers = false;
      uid = 0;
      gid = 0;
    } secrets_."database.password")
    (assertEqual "user template path" "/run/user/1000/secrets/cloud.token" secrets_."cloud.token".path)
  ];
  configFor =
    enabled: accounts:
    (lib.evalModules {
      specialArgs.pkgs = { };
      modules = [
        sops
        {
          options = {
            users.users = lib.mkOption { type = lib.types.raw; };
            users.groups = lib.mkOption {
              type = lib.types.raw;
              default = { };
            };
            environment.systemPackages = lib.mkOption { type = lib.types.raw; };
            age.secrets = lib.mkOption {
              type = lib.types.raw;
              default = { };
            };
          };
          config = {
            users.users = accounts;
            features.sops = {
              enable = enabled;
              authorizedUids = [ 1000 ];
            };
          };
        }
      ];
    }).config;
  membersFor = accounts: (configFor true accounts).users.groups.sops-decrypt.members;
  disabled = configFor false (throw "Disabled SOPS must not resolve authorized accounts");
  fails = value: !(builtins.tryEval (builtins.deepSeq value true)).success;

in
assert builtins.deepSeq tests_ true;
assert disabled.users.groups == { };
assert disabled.age.secrets == { };
assert
  membersFor {
    different-key = {
      uid = 1000;
      name = "actual-user";
    };
  } == [ "actual-user" ];
assert fails (membersFor { });
assert fails (membersFor {
  first = {
    uid = 1000;
    name = "first";
  };
  second = {
    uid = 1000;
    name = "second";
  };
});
runCommand "nixos-sops-functions" { } ''
  touch $out
''
