{ lib }: rec {

  mkOptionName = path: lib.showOption path;

  discoverModules =
    modules:
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
          (path == [ "modules" ])
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
            traverse (module + "/${name}") (builtins.concatLists [
              path
              [ name ]
            ]) (if isModule then path else parentModulePath)
          ) childDirectories)
        ]
    ))
      modules
      [ "modules" ]
      null;

  discoverValidatorFiles =
    { modules }:
    let
      base = [ "modules" ];
      paths = lib.unique (
        [ base ]
        ++ builtins.concatMap (
          descriptor:
          builtins.map (length: lib.take length descriptor.path) (
            lib.range (builtins.length base) (builtins.length descriptor.path)
          )
        ) (discoverModules modules)
      );
      ordered = builtins.sort (
        a: b:
        if builtins.length a == builtins.length b then
          lib.concatStringsSep "/" a < lib.concatStringsSep "/" b
        else
          builtins.length a < builtins.length b
      ) paths;
    in
    builtins.filter (entry: builtins.pathExists entry.file) (
      builtins.map (path: {
        inherit path;
        file = modules + "/${lib.concatStringsSep "/" (lib.drop 1 path)}/_validators.fp.nix";
      }) ordered
    );

  mkOptionModules = rec {
    default =
      {
        modules,
        scope,
        target,
      }:
      path:
      let
        prefixes = lib.range 1 (builtins.length path);
        optionFiles = builtins.filter builtins.pathExists (
          builtins.map (
            length: modules + "/${lib.concatStringsSep "/" (lib.drop 1 (lib.take length path))}/_options.fp.nix"
          ) prefixes
        );
      in
      builtins.map (file: {
        _file = file;
        options =
          (import file (
            lib.mergeAttrsList [
              scope
              { inherit path; }
            ]
          )).${target};
      }) optionFiles;

    configuration =
      {
        modules,
        scope,
        metadata,
      }:
      path:
      builtins.map
        (
          module:
          module
          // {
            options = if lib.isFunction module.options then module.options metadata else module.options;
          }
        )
        (
          default {
            inherit modules scope;
            target = "configuration";
          } path
        );

    metadata =
      { modules, scope }:
      default {
        inherit modules scope;
        target = "metadata";
      };
  };

  mkOptionTree =
    {
      modules,
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
    ) { } (discoverModules modules);

}
