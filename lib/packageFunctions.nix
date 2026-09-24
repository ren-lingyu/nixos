{ lib } : let

  getDirectories_ = path_ : (lib.mapAttrs
    (name_ : unused_type_ : path_ + "/${name_}")
    (lib.filterAttrs
      (unused_name_ : type_ : type_ == "directory")
      (builtins.readDir path_)
    )
  );

  packagePath_ = path_ : path_ + "/package.nix";

  overlayPath_ = path_ : path_ + "/overlay.nix";

  hasPackage_ = path_ : builtins.pathExists (packagePath_ path_);

  hasOverlay_ = path_ : builtins.pathExists (overlayPath_ path_);

  isLeaf_ = path_ : (builtins.any
    (x_ : x_)
    [
      (hasPackage_ path_)
      (hasOverlay_ path_)
    ]
  );

  hasPackages_ = path_ : (builtins.any
    (child_ :
      if isLeaf_ child_
      then hasPackage_ child_
      else hasPackages_ child_
    )
    (builtins.attrValues (getDirectories_ path_))
  );

  hasOverlays_ = path_ : (builtins.any
    (child_ :
      if isLeaf_ child_
      then hasOverlay_ child_
      else hasOverlays_ child_
    )
    (builtins.attrValues (getDirectories_ path_))
  );

  mkLegacyPackages_ = pkgs_ : root_ : (lib.mapAttrs
    (unused_name_ : child_ :
      if hasPackage_ child_
      then pkgs_.callPackage (packagePath_ child_) {}
      else mkScope_ pkgs_ child_
    )
    (lib.filterAttrs
      (unused_name_ : child_ :
        if isLeaf_ child_
        then hasPackage_ child_
        else hasPackages_ child_
      )
      (getDirectories_ root_)
    )
  );

  mkScope_ = pkgs_ : root_ : (lib.makeScope
    pkgs_.newScope
    (self_ : mkLegacyPackages_ self_ root_)
  );

  mkScopeOverlay_ = name_ : root_ : let

    overlay_ = mkOverlay_ root_;

  in final_ : prev_ : (lib.setAttrByPath
    [ name_ ]
    (
      if builtins.hasAttr name_ prev_
      then let

        previous_ = builtins.getAttr name_ prev_;

      in (
        if (builtins.all
          (x_ : x_)
          [
            (builtins.isAttrs previous_)
            (previous_ ? overrideScope)
          ]
        )
        then previous_.overrideScope overlay_
        else builtins.throw "packageFunctions.mkOverlay: `${name_}` already exists and is not a package scope"
      )
      else (lib.makeScope
        final_.newScope
        (self_ : overlay_ self_ {})
      )
    )
  );

  mkOverlay_ = root_ : let

    directories_ = getDirectories_ root_;

    leafOverlays_ = (lib.mapAttrsToList
      (unused_name_ : child_ : import (overlayPath_ child_))
      (lib.filterAttrs
        (unused_name_ : child_ : (builtins.all
          (x_ : x_)
          [
            (isLeaf_ child_)
            (hasOverlay_ child_)
          ]
        ))
        directories_
      )
    );

    scopeOverlays_ = (lib.mapAttrsToList
      (name_ : child_ : mkScopeOverlay_ name_ child_)
      (lib.filterAttrs
        (unused_name_ : child_ : (builtins.all
          (x_ : x_)
          [
            (!isLeaf_ child_)
            (hasOverlays_ child_)
          ]
        ))
        directories_
      )
    );

  in (lib.composeManyExtensions
    (builtins.concatLists [
      leafOverlays_
      scopeOverlays_
    ])
  );

in {

  mkLegacyPackages = {
    root,
    pkgs,
  } : (mkLegacyPackages_ pkgs root);

  mkOverlay = {
    root,
  } : (mkOverlay_ root);

}
