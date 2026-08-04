{ pkgs, llib } : let

  groupedImports_ = llib.moduleFunctions.features.default.groupImportsByUid
    (unused_name_ : item_ : item_.uids)
    (name_ : unused_item_ : [ "${name_}-hm" ])
    {
      alpha.uids = [ 1000 1001 ];
      beta.uids = [ 1000 1002 ];
      empty.uids = [];
    };

  expected_ = {
    "1000" = [ "beta-hm" "alpha-hm" ];
    "1001" = [ "alpha-hm" ];
    "1002" = [ "beta-hm" ];
  };

in assert groupedImports_ == expected_; pkgs.runCommand "nixos-feature-import-grouping" {} ''
  touch $out
''
