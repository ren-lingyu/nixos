{ lib } : {

  groupImportsByUid = getUids : getImports : items : lib.foldlAttrs (importsByUid_ : itemName_ : item_ : let
    uids_ = getUids itemName_ item_;
    imports_ = getImports itemName_ item_;
  in (
    builtins.foldl' (userImportsByUid_ : uid_ : let
      uidString_ = builtins.toString uid_;
    in (
      if builtins.hasAttr uidString_ userImportsByUid_
      then userImportsByUid_ // { "${uidString_}" = imports_ ++ userImportsByUid_."${uidString_}"; }
      else userImportsByUid_ // { "${uidString_}" = imports_; }
    )) importsByUid_ uids_
  )) {} items;

}
