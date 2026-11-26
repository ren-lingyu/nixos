{
  lib,
  runCommand,
  modules,
  secrets,
}:
let
  inherit (lib) mkOption types;

  accounts = {
    "1000".username = "first";
    "1001".username = "second";
    "1002".username = "empty";
  };

  evaluate =
    extra:
    (lib.evalModules {
      specialArgs = {
        inherit accounts;
        llib = { inherit secrets; };
      };
      modules = [
        (modules + "/base/os/secrets.nix")
        ({ config, llib, ... }: {
          options = {
            age.secrets = mkOption {
              type = types.attrsOf (
                types.submodule (
                  { name, ... }: {
                    options = {
                      rekeyFile = mkOption { type = types.path; };
                      owner = mkOption { type = types.str; };
                      group = mkOption { type = types.str; };
                      mode = mkOption { type = types.str; };
                      path = mkOption {
                        type = types.str;
                        default = "/mock/agenix/${name}";
                      };
                    };
                  }
                )
              );
              default = { };
            };
            home-manager.users = mkOption {
              type = types.attrsOf (
                types.submoduleWith {
                  specialArgs = {
                    osConfig = config;
                    inherit llib;
                  };
                  modules = [
                    (modules + "/base/hm/secrets.nix")
                    ({ name, ... }: {
                      options.home.uid = mkOption {
                        type = types.int;
                        default = builtins.fromJSON name;
                      };
                    })
                  ];
                }
              );
              default = { };
            };
          };
          config.home-manager.users = lib.mapAttrs (_: _: { }) accounts;
        })
      ]
      ++ extra;
    }).config;

  # Two separate HM modules contribute leaves in the same branch. The first
  # Account also has a root-level leaf and a branch named path.
  os = evaluate [
    {
      home-manager.users."1000".secrets = {
        root.rekeyFile = ./test.nix;
        cloud.api.key.rekeyFile = lib.mkDefault ./test-overlay.nix;
        path.token.rekeyFile = ./test.nix;
        unused = { };
        disabled = lib.mkIf false { rekeyFile = ./test.nix; };
      };
      home-manager.users."1001".secrets.cloud.api.key.rekeyFile = ./test-overlay.nix;
      age.secrets."secrets.user.1000.cloud.api.key".path = "/mock/custom-key";
    }
    {
      home-manager.users."1000".secrets.cloud.api = {
        key.rekeyFile = ./test.nix;
        other.rekeyFile = ./test-overlay.nix;
      };
    }
  ];

  hm = os.home-manager.users;

  fails =
    tree:
    !(builtins.tryEval (
      builtins.deepSeq (evaluate [ { home-manager.users."1000".secrets = tree; } ]).age.secrets true
    )).success;

  # Force the HM output to verify the read-only contract independently.
  explicitPath = evaluate [
    {
      home-manager.users."1000".secrets.key = {
        rekeyFile = ./test.nix;
        path = "/incorrect";
      };
    }
  ];

  mixed = evaluate [
    { home-manager.users."1000".secrets.key.rekeyFile = ./test.nix; }
    { home-manager.users."1000".secrets.key.child.rekeyFile = ./test.nix; }
  ];
in
assert
  secrets.userSecretName 1000 [
    "a"
    "b"
  ] == "secrets.user.1000.a.b";
assert
  secrets.userSecretName "1000" [
    "a"
    "b"
  ] == "secrets.user.1000.a.b";
assert (evaluate [ ]).age.secrets == { };
assert hm."1002".secrets == { };
assert
  builtins.attrNames os.age.secrets == [
    "secrets.user.1000.cloud.api.key"
    "secrets.user.1000.cloud.api.other"
    "secrets.user.1000.path.token"
    "secrets.user.1000.root"
    "secrets.user.1001.cloud.api.key"
  ];
assert
  os.age.secrets."secrets.user.1000.cloud.api.key" == {
    rekeyFile = ./test.nix;
    owner = "first";
    group = "root";
    mode = "0400";
    path = "/mock/custom-key";
  };
assert os.age.secrets."secrets.user.1001.cloud.api.key".owner == "second";
assert os.age.secrets."secrets.user.1001.cloud.api.key".rekeyFile == ./test-overlay.nix;
assert hm."1000".secrets.cloud.api.key.path == "/mock/custom-key";
assert hm."1000".secrets.cloud.api.other.path == "/mock/agenix/secrets.user.1000.cloud.api.other";
assert hm."1000".secrets.root.path == "/mock/agenix/secrets.user.1000.root";
assert hm."1001".secrets.cloud.api.key.path == "/mock/agenix/secrets.user.1001.cloud.api.key";
assert fails { "a.b".rekeyFile = ./test.nix; };
assert fails { "a/b".rekeyFile = ./test.nix; };
assert fails { "".rekeyFile = ./test.nix; };
assert fails { rekeyFile.rekeyFile = ./test.nix; };
assert fails { key = "not a node"; };
assert fails { key.rekeyFile = 42; };
assert fails { key.path = "/not-a-leaf"; };
assert fails {
  key = {
    rekeyFile = ./test.nix;
    child.rekeyFile = ./test.nix;
  };
};
assert !(builtins.tryEval (builtins.deepSeq mixed.age.secrets true)).success;
assert !(builtins.tryEval explicitPath.home-manager.users."1000".secrets.key.path).success;
runCommand "user-secrets" { } "touch $out"
