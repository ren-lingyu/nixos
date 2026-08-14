{ pkgs, llib } : let

  assertEqual = name_ : expected_ : actual_ :
    if actual_ == expected_
    then true
    else throw "Test `${name_}` failed: values differ.";

  sopsFunctions_ = llib.moduleFunctions.features.sops {
    config = {
      home.uid = 1000;
      sops = {
        defaultSopsFormat = "yaml";
        defaultSopsFile = ./default.nix;
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
      structure.cloud.token = [];
    }
  ];

  tests_ = [
    (assertEqual "structure expansion" [
      [ "empty" ]
      [ "list" "first" ]
      [ "list" "second" ]
      [ "nested" "leaf" ]
    ] (sopsFunctions_.fromStructure {
      empty = [];
      ignored = "value";
      list = [ "first" "second" ];
      nested.leaf = [];
    }))
    (assertEqual "system template" {
      name = "database.password";
      key = "database/password";
      mode = "0440";
      path = "/run/secrets/database.password";
      format = "yaml";
      sopsFile = ./default.nix;
      neededForUsers = false;
      uid = 0;
      gid = 0;
    } secrets_."database.password")
    (assertEqual "user template path" "/run/user/1000/secrets/cloud.token" secrets_."cloud.token".path)
  ];

in assert builtins.deepSeq tests_ true; pkgs.runCommand "nixos-sops-functions" {} ''
  touch $out
''
