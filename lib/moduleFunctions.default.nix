{ lib }: rec {

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

  mkOptionName = path: lib.showOption path;

  # Resolve deferred configuration values only after NixOS has supplied its final context.
  # Do not traverse derivations: their attributes include function-valued helpers.
  resolveFunOf =
    scope: value:
    if builtins.isFunction value then
      resolveFunOf scope (value scope)
    else if builtins.isList value then
      builtins.map (resolveFunOf scope) value
    else if
      builtins.all (condition: condition) [
        (builtins.isAttrs value)
        (!(lib.isDerivation value))
      ]
    then
      builtins.mapAttrs (unused_name: resolveFunOf scope) value
    else
      value;

  discoverModules =
    rootDirectory: searchDirectory:
    let
      rootPath = lib.splitString "/" (toString rootDirectory);
      searchPath = lib.splitString "/" (toString searchDirectory);

      relativePath = lib.drop (builtins.length rootPath) searchPath;
    in
    assert lib.assertMsg (
      lib.take (builtins.length rootPath) searchPath == rootPath
    ) "discoverModules: searchDirectory must be contained in rootDirectory.";
    (lib.fix (
      traverse: module: path: parentModulePath:
      let
        osPath = module + "/os/default.nix";
        hmPath = module + "/hm/default.nix";

        os = if builtins.pathExists osPath then osPath else null;
        hm = if builtins.pathExists hmPath then hmPath else null;

        isModule = builtins.any (value: value != null) [
          os
          hm
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
          ) (builtins.readDir module)
        );

      in
      if
        builtins.all (condition: condition) [
          isModule
          (path == relativePath)
        ]
      then
        throw "discoverModules: the search directory cannot be a module."
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
            "Child: ${lib.concatStringsSep "/" path}"
          ]
        )
      else
        builtins.concatLists [
          (lib.optional isModule {
            inherit
              path
              module
              os
              hm
              ;
          })
          (builtins.concatMap (
            name:
            traverse (module + "/${name}") (path ++ [ name ]) (if isModule then path else parentModulePath)
          ) childDirectories)
        ]
    ))
      searchDirectory
      relativePath
      null;

  mkOptionModules =
    { root, scope }:
    path:
    let
      prefixes = lib.range 1 (builtins.length path);
      optionFiles = builtins.filter builtins.pathExists (
        builtins.map (
          length: root + "/${lib.concatStringsSep "/" (lib.take length path)}/_options.nix"
        ) prefixes
      );
    in
    builtins.map (file: {
      _file = file;
      options = import file (scope // { inherit path; });
    }) optionFiles;

  mkOptionTree =
    {
      root,
      modulesDir,
      pathMapper ? lib.id,
      optionMaker,
    }:
    lib.foldl' (
      tree: module:
      let
        path = pathMapper module.path;
      in
      if path == [ ] then
        throw "mkOptionTree: option path must not be empty."
      else if lib.hasAttrByPath path tree then
        throw "mkOptionTree: duplicate option path `${lib.concatStringsSep "." path}`."
      else
        lib.recursiveUpdate tree (lib.setAttrByPath path (optionMaker module))
    ) { } (discoverModules root modulesDir);

}
