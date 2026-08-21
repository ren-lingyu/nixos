{ lib } : let

  mkModuleOptions_ = {
    path_,
    commonSchema_,
    extraSchema_,
  } : (lib.genAttrs
    (builtins.attrNames
      (lib.filterAttrs
        (name_ : type_ : (builtins.all
          (x_ : x_)
          [
            (type_ == "directory")
            (builtins.pathExists (path_ + "/${name_}/default.nix"))
          ]
        ))
        (builtins.readDir path_)
      )
    )
    (module_ : (lib.mergeAttrsList [
      (commonSchema_
        module_
      )
      (extraSchema_
        module_
        (path_ + "/${builtins.toString module_}/extra-options.nix")
      )
    ]))
  );

in {

  mkModuleOptions = {

    default = {
      path,
      commonSchema,
      extraScope,
    } : (mkModuleOptions_ {
      path_ = path;
      commonSchema_ = commonSchema;
      extraSchema_ = (module_ : possibleExtraOptionsPath_ : (lib.optionalAttrs
        (builtins.pathExists possibleExtraOptionsPath_)
        ((import possibleExtraOptionsPath_)
          module_
          extraScope
        ))
      );
    });

    withoutExtra = {
      path,
      commonSchema,
    } : (mkModuleOptions_ {
      path_ = path;
      commonSchema_ = commonSchema;
      extraSchema_ = (x_ : y_ : {});
    });

  };

}
