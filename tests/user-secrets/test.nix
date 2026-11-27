{
  lib,
  runCommand,
  modules,
  secrets,
}:
let
  inherit (lib) mkOption types;

  evaluateTrees =
    extra:
    (lib.evalModules {
      modules = [
        {
          options = {
            declarations = mkOption {
              type = secrets.declarationType;
              default = { };
            };
            selections = mkOption {
              type = secrets.selectionType;
              default = { };
            };
          };
        }
      ]
      ++ extra;
    }).config;

  trees = evaluateTrees [
    {
      declarations = {
        root.rekeyFile = ./test.nix;
        cloud.api.key.rekeyFile = lib.mkDefault ./test-overlay.nix;
        path.token.rekeyFile = ./test.nix;
        unused.rekeyFile = ./test.nix;
        disabled.rekeyFile = ./test.nix;
        empty = { };
      };
      selections = {
        root.enable = true;
        cloud.api.key.enable = true;
        path.token.enable = true;
        disabled.enable = false;
      };
    }
    {
      declarations.cloud.api = {
        key.rekeyFile = ./test.nix;
        other.rekeyFile = ./test-overlay.nix;
      };
      selections.cloud.api.other.enable = true;
    }
  ];

  accounts = {
    "1000" = {
      username = "first";
      secrets = secrets.selectTree trees.declarations trees.selections;
    };
    "1001" = {
      username = "second";
      secrets = secrets.selectTree trees.declarations { cloud.api.other.enable = true; };
    };
    "1002" = {
      username = "empty";
      secrets = secrets.selectTree trees.declarations { };
    };
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
        {
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
              type = types.attrsOf (types.submodule (modules + "/base/hm/secrets.nix"));
              default = { };
            };
          };
        }
      ]
      ++ extra;
    }).config;

  os = evaluate [ { age.secrets."secrets.user.1000.cloud.api.key".path = "/mock/custom-key"; } ];
  hm = os.home-manager.users;

  fails = extra: !(builtins.tryEval (builtins.deepSeq (evaluateTrees extra) true)).success;

  failsSelection =
    selection:
    !(builtins.tryEval (builtins.deepSeq (secrets.selectTree trees.declarations selection) true))
    .success;

  explicitPath = evaluate [ { home-manager.users."1000".secrets.key.path = "/incorrect"; } ];
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
assert secrets.selectTree trees.declarations { } == { };
assert secrets.selectTree trees.declarations { cloud.api.key.enable = false; } == { };
assert hm."1002".secrets == { };
assert
  builtins.attrNames os.age.secrets == [
    "secrets.user.1000.cloud.api.key"
    "secrets.user.1000.cloud.api.other"
    "secrets.user.1000.path.token"
    "secrets.user.1000.root"
    "secrets.user.1001.cloud.api.other"
  ];
assert
  os.age.secrets."secrets.user.1000.cloud.api.key" == {
    rekeyFile = ./test.nix;
    owner = "first";
    group = "root";
    mode = "0400";
    path = "/mock/custom-key";
  };
assert os.age.secrets."secrets.user.1001.cloud.api.other".owner == "second";
assert os.age.secrets."secrets.user.1001.cloud.api.other".rekeyFile == ./test-overlay.nix;
assert hm."1000".secrets.cloud.api.key == { path = "/mock/custom-key"; };
assert hm."1000".secrets.cloud.api.other.path == "/mock/agenix/secrets.user.1000.cloud.api.other";
assert hm."1000".secrets.root.path == "/mock/agenix/secrets.user.1000.root";
assert hm."1000".secrets.path.token.path == "/mock/agenix/secrets.user.1000.path.token";
assert hm."1001".secrets.cloud.api.other.path == "/mock/agenix/secrets.user.1001.cloud.api.other";
assert !(hm."1000".secrets ? unused);
assert !(hm."1000".secrets ? disabled);
assert !(hm."1001".secrets.cloud.api ? key);
assert failsSelection { unknown.enable = false; };
assert failsSelection { cloud.enable = true; };
assert failsSelection { root.child.enable = true; };
assert fails [ { declarations."a.b".rekeyFile = ./test.nix; } ];
assert fails [ { declarations."a/b".rekeyFile = ./test.nix; } ];
assert fails [ { declarations."".rekeyFile = ./test.nix; } ];
assert fails [ { declarations.rekeyFile.rekeyFile = ./test.nix; } ];
assert fails [ { declarations.enable.rekeyFile = ./test.nix; } ];
assert fails [ { declarations.key = "not a node"; } ];
assert fails [ { declarations.key.rekeyFile = 42; } ];
assert fails [ { declarations.key.path = "/not-a-leaf"; } ];
assert fails [ { selections.key.enable = "true"; } ];
assert fails [ { selections.key.rekeyFile = ./test.nix; } ];
assert fails [
  { declarations.key.rekeyFile = ./test.nix; }
  { declarations.key.child.rekeyFile = ./test.nix; }
];
assert fails [
  { selections.key.enable = true; }
  { selections.key.child.enable = true; }
];
assert
  !(builtins.tryEval (builtins.deepSeq explicitPath.home-manager.users."1000".secrets true)).success;
runCommand "user-secrets" { } "touch $out"
