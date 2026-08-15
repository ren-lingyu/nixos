{ lib } : {

  getUniqueEnabledHost = hosts_ : let
    enabledHostValues_ = builtins.attrValues (
      (lib.filterAttrs
        (unused_name_ : host_ : (host_.enable or false) == true)
        hosts_
      )
    );
  in (
    if (builtins.length enabledHostValues_) == 1
    then builtins.head enabledHostValues_
    else {}
  );

}
