{ lib } : let

  getDirectories_ = path_ : (lib.mapAttrs
    (name_ : unused_type_ : path_ + "/${name_}")
    (lib.filterAttrs
      (unused_name_ : type_ : type_ == "directory")
      (builtins.readDir path_)
    )
  );

  resolvePath_ = relativePath_ : path_ : path_ + "/${relativePath_}";

  hasPath_ = relativePath_ : path_ : builtins.pathExists (resolvePath_ relativePath_ path_);

  hasEntries_ = relativePath_ : path_ : (builtins.any
    (child_ :
      if hasPath_ relativePath_ child_
      then true
      else hasEntries_ relativePath_ child_
    )
    (builtins.attrValues (getDirectories_ path_))
  );

  mkLegacyPackages_ = packagePath_ : pkgs_ : root_ : (lib.mapAttrs
    (unused_name_ : child_ :
      if hasPath_ packagePath_ child_
      then pkgs_.callPackage (resolvePath_ packagePath_ child_) {}
      else mkScope_ packagePath_ pkgs_ child_
    )
    (lib.filterAttrs
      (unused_name_ : child_ :
        if hasPath_ packagePath_ child_
        then true
        else hasEntries_ packagePath_ child_
      )
      (getDirectories_ root_)
    )
  );

  mkScope_ = packagePath_ : pkgs_ : root_ : (lib.makeScope
    pkgs_.newScope
    (self_ : mkLegacyPackages_ packagePath_ self_ root_)
  );

  mkAttrsetOverlay_ = final_ : previous_ : overlay_ : let

    scope_ = (lib.makeScope
      final_.newScope
      (self_ : (lib.mergeAttrsList [
        previous_
        (overlay_ self_ previous_)
      ]))
    );

  in (lib.mergeAttrsList [
    previous_
    (overlay_ scope_ previous_)
  ]);

  mkNamespaceOverlay_ = overlayPath_ : name_ : root_ : let

    overlay_ = mkOverlay_ overlayPath_ root_;

  in final_ : prev_ : (lib.setAttrByPath
    [ name_ ]
    (
      if builtins.hasAttr name_ prev_
      then let

        previous_ = builtins.getAttr name_ prev_;

      in (
        if builtins.isAttrs previous_
        then (
          if lib.isDerivation previous_
          then builtins.throw "packageFunctions.mkOverlay: `${name_}` already exists and is a derivation"
          else (
            if previous_ ? overrideScope
            then previous_.overrideScope overlay_
            else mkAttrsetOverlay_ final_ previous_ overlay_
          )
        )
        else builtins.throw "packageFunctions.mkOverlay: `${name_}` already exists and is not an attribute set"
      )
      else (lib.makeScope
        final_.newScope
        (self_ : overlay_ self_ {})
      )
    )
  );

  mkOverlay_ = overlayPath_ : root_ : let

    directories_ = getDirectories_ root_;

    localOverlays_ = (lib.mapAttrsToList
      (unused_name_ : child_ : import (resolvePath_ overlayPath_ child_))
      (lib.filterAttrs
        (unused_name_ : child_ : hasPath_ overlayPath_ child_)
        directories_
      )
    );

    namespaceOverlays_ = (lib.mapAttrsToList
      (name_ : child_ : mkNamespaceOverlay_ overlayPath_ name_ child_)
      (lib.filterAttrs
        (unused_name_ : child_ : hasEntries_ overlayPath_ child_)
        directories_
      )
    );

  in (lib.composeManyExtensions
    (builtins.concatLists [
      localOverlays_
      namespaceOverlays_
    ])
  );

  mkModule_ = modulePath_ : root_ : {

    imports = (builtins.concatLists
      (lib.mapAttrsToList
        (unused_name_ : child_ :
          if hasPath_ modulePath_ child_
          then [ (resolvePath_ modulePath_ child_) ]
          else (mkModule_ modulePath_ child_).imports
        )
        (getDirectories_ root_)
      )
    );

  };

in {

  mkLegacyPackages = {
    root,
    pkgs,
    packagePath,
  } : (mkLegacyPackages_ packagePath pkgs root);

  mkOverlay = {
    root,
    overlayPath,
  } : (mkOverlay_ overlayPath root);

  mkNixosModule = {
    root,
    modulePath,
  } : (mkModule_ modulePath root);

  mkHomeManagerModule = {
    root,
    modulePath,
  } : (mkModule_ modulePath root);

}
