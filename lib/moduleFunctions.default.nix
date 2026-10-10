{ lib }: {

  mkModuleOptions =
    let

      mkModuleOptions_ =
        {
          path_,
          commonSchema_,
          extraSchema_,
        }:
        (lib.genAttrs
          (builtins.attrNames (
            lib.filterAttrs (
              name_: type_:
              (builtins.all (x_: x_) [
                (type_ == "directory")
                (builtins.pathExists (path_ + "/${name_}/default.nix"))
              ])
            ) (builtins.readDir path_)
          ))
          (
            module_:
            (lib.mergeAttrsList [
              (commonSchema_ module_)
              (extraSchema_ module_ (path_ + "/${builtins.toString module_}/extra-options.nix"))
            ])
          )
        );

    in
    {

      default =
        {
          path,
          commonSchema,
          extraScope,
        }:
        (mkModuleOptions_ {
          path_ = path;
          commonSchema_ = commonSchema;
          extraSchema_ = (
            module_: possibleExtraOptionsPath_:
            (lib.optionalAttrs (builtins.pathExists possibleExtraOptionsPath_) (
              (import possibleExtraOptionsPath_) module_ extraScope
            ))
          );
        });

      withoutExtra =
        { path, commonSchema }:
        (mkModuleOptions_ {
          path_ = path;
          commonSchema_ = commonSchema;
          extraSchema_ = (x_: y_: { });
        });

    };

  discoverModules =
    rootDirectory:
    (lib.fix (
      traverse: directory: relativePath: parentModulePath:
      let
        osPath = directory + "/os/default.nix";
        hmPath = directory + "/hm/default.nix";

        os = if builtins.pathExists osPath then osPath else null;
        hm = if builtins.pathExists hmPath then hmPath else null;

        isModule = builtins.any (value: value) [
          (os != null)
          (hm != null)
        ];

        childDirectories = builtins.attrNames (
          lib.filterAttrs (
            name: kind:
            builtins.all (condition: condition) [
              (kind == "directory")
              (
                !(builtins.elem name [
                  "os"
                  "hm"
                ])
              )
            ]
          ) (builtins.readDir directory)
        );

      in
      if
        builtins.all (condition: condition) [
          isModule
          (relativePath == [ ])
        ]
      then
        throw "discoverModules: the root directory cannot be a module."
      else if
        builtins.all (condition: condition) [
          isModule
          (parentModulePath != null)
        ]
      then
        throw (
          builtins.concatStringsSep "\n" [
            "discoverModules: nested modules are not allowed."
            "Parent: ${lib.concatStringsSep "/" parentModulePath}"
            "Child: ${lib.concatStringsSep "/" relativePath}"
          ]
        )
      else
        builtins.concatLists [
          (lib.optional isModule {
            path = relativePath;
            inherit directory os hm;
          })
          (builtins.concatMap (
            name:
            traverse (directory + "/${name}") (builtins.concatLists [
              relativePath
              [ name ]
            ]) (if isModule then relativePath else parentModulePath)
          ) childDirectories)
        ]
    ))
      rootDirectory
      [ ]
      null;

  mkOptionTree =
    mkModuleOptionDeclarations: moduleDescriptors:
    lib.foldl' (
      optionTree: moduleDescriptor:
      if moduleDescriptor.path == [ ] then
        throw "mkOptionTree: module path must not be empty."
      else if lib.hasAttrByPath moduleDescriptor.path optionTree then
        throw "mkOptionTree: duplicate module path `${lib.concatStringsSep "." moduleDescriptor.path}`."
      else
        lib.recursiveUpdate optionTree (
          lib.setAttrByPath moduleDescriptor.path (mkModuleOptionDeclarations moduleDescriptor)
        )
    ) { } moduleDescriptors;

}
